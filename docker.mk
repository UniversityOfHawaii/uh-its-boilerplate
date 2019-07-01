### ARGUMENTS
# DOCKER_TOOLS_VERSION: version of docker-tools image to use
DOCKER_TOOLS_VERSION ?= 2018.10.12
# swarm: DEV|TEST|QA|PROD|DEV_AS_TEST|DEV_AS_QA|DEV_AS_PROD
swarm ?= DEV


### CONFIGURATION BASED ON WHETHER DEV OR CI IS BUILDING. DEFAULTS TO DEV.
composeDisableTTY =
runInteractively = -it
sourceFilesOwner = $(shell id -u)
containerSourceFilesOwner = $(sourceFilesOwner)
sshPseudoTTY = -tt
integrationTestingCISecrets =
DOCKER_TOOLS_COMMAND = docker run --rm $(runInteractively) \
	-v /var/run/docker.sock:/var/run/docker.sock \
	registry.pvt.hawaii.edu/docker-tools:$(DOCKER_TOOLS_VERSION)
ifdef JENKINS_HOME
	composeDisableTTY = -T
	runInteractively =
	sourceFilesOwner = 105000
	# When using a stack to run a one-off command with the development images,
	# we can't use host user-namespace because it needs to be deployed in a stack
	# (since we're using docker secrets). So we have to set it to the container
	# user instead.
	containerSourceFilesOwner = 5000
	gradleConsole = --console=auto
	sshPseudoTTY =

	# On one of the swarms, jenkins needs to give docker-tools access to the tcp socket
	# instead of using the unix socket directly. Since we may be on TEST, QA, or PROD
	# the DOCKER_HOST variable needs to be set externally by the Jenkins job as an
	# environment variable.
	DOCKER_TOOLS_COMMAND = docker run --rm $(runInteractively) \
		-v /swarm-volumes/docker-tools/certs:/root/.docker \
		-e DOCKER_TLS_VERIFY=1 \
		-e DOCKER_HOST=$(DOCKER_HOST) \
		registry.pvt.hawaii.edu/docker-tools:$(DOCKER_TOOLS_VERSION)

endif

stackName = $(PROJECT_NAME)
ifdef VERSION
  stackName = $(PROJECT_NAME)_$(subst .,_,$(VERSION))
endif


################################################################################
### REGISTRY
################################################################################

# $(1) = The registry.
# $(2) = The service name.
define lsRegistry
	curl -s https://$(1).pvt.hawaii.edu/v2/$(2)/tags/list \
	| xargs -0 \
	node -e "console.log(JSON.stringify(JSON.parse(process.argv[1]), null, 2))"
endef

# $(1) = The registry.
# $(2) = The image's digest.
# The `tr -d '\015'` part removes a hidden carriage return from parsing the digest
define rmRegistryImage
	@export DIGEST=`curl -I -s \
		--header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
		https://$(1).pvt.hawaii.edu/v2/$(2)/manifests/$(tag) \
		| grep Docker-Content-Digest \
		| cut -d ':' -f2- \
		| tr -d ' ' \
		| tr -d '\015'` \
	&& echo "$(red)Deleting$(endColor):" \
	&& echo "    image:    $(cyan)$(2)$(endColor)" \
	&& echo "    tag:      $(cyan)$(tag)$(endColor)" \
	&& echo "    digest:   $(cyan)$$DIGEST$(endColor)" \
	&& echo "    registry: $(cyan)$(1)$(endColor)" \
	&& curl -X DELETE https://$(1).pvt.hawaii.edu/v2/$(2)/manifests/$$DIGEST
endef

define dockerDebugInfo
$(yellow)Debug common.mk config$(endColor)
\tswarm: $(cyan)$(swarm)$(endColor)
\tsourceFilesOwner: $(cyan)$(sourceFilesOwner)$(endColor)
\tcontainerSourceFilesOwner: $(cyan)$(containerSourceFilesOwner)$(endColor)
\tstackName: $(cyan)$(stackName)$(endColor)
endef

export dockerDebugInfo
debug-common: ##2 (docker) displays low-level docker@UH configuration values
	@echo "$$dockerDebugInfo"
