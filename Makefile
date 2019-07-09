.DEFAULT_GOAL := help
##
# External environment variables, set in the Jenkinsfile
#   TARGET_ENV = test
#   BUILD_VERSION = releaseDataFromGit.versionFromGitStatus()
#   REGISTRY = releaseDataFromGit.registryFromGitStatus()
##

TARGET_ENV ?= dev
ifeq ($(TARGET_ENV),test)
	DCFILE=docker-compose/test.yml

	REGISTRY ?= registry-qa.pvt.hawaii.edu/
	BUILD_VERSION ?= SNAPSHOT
else
	DCFILE=docker-compose/dev.yml

	REGISTRY := ""
	BUILD_VERSION := SNAPSHOT
endif

PROJECT_NAME := uh-its-boilerplate
SERVICE_NAME := server
STACK_NAME := boilerplate_$(BUILD_VERSION)

include mk/shared/common.mk

define ADD_TRAEFIK_LABELS
--label-add traefik.enable="true" \
--label-add traefik.http.routers.$(STACK_NAME)-router.rule="PathPrefix(\`/boilerplate/$(BUILD_VERSION)\`)" \
--label-add traefik.http.routers.$(STACK_NAME)-router.middlewares="$(STACK_NAME)-middleware1" \
--label-add traefik.http.middlewares.$(STACK_NAME)-middleware1.stripprefix.prefixes="/boilerplate/$(BUILD_VERSION)" \
--label-add traefik.http.routers.$(STACK_NAME)-router.service="$(STACK_NAME)-service" \
--label-add traefik.http.services.$(STACK_NAME)-service.loadbalancer.server.port="80"
endef

COMPOSE_COMMON := -p $(PROJECT_NAME) -b $(BUILD_VERSION) -r $(REGISTRY)

build-image: ## (custom,image) builds the image
	@sh/dcompose.sh $(COMPOSE_COMMON) -f $(DCFILE) build

publish-image: ## (custom,image) publishes the image
	@sh/dcompose.sh $(COMPOSE_COMMON) -f $(DCFILE) push $(SERVICE_NAME)

deploy: ## (custom,image) deploys the stack
	BUILD_VERSION=$(BUILD_VERSION) docker stack deploy -c $(DCFILE) $(STACK_NAME)
	@sh/stackIsUp.sh $(STACK_NAME)

add-traefik-labels: ## (custom,image) adds traefik labels to the stack's service
	docker service update $(ADD_TRAEFIK_LABELS) $(STACK_NAME)_server

undeploy: ## (custom,image) undeploys the stack
	@docker stack rm $(STACK_NAME)
	@(docker network rm $(shell docker network ls -q --filter Name=$(PROJECT_NAME)) 1>/dev/null 2>&1 || true)
	@sh/stackIsDown.sh $(STACK_NAME)

manual-build-test-image: ## (custom,image) builds the image using test-environment values
	TARGET_ENV=test $(MAKE) build-image

manual-publish-test-image: ## (custom,image) publishes the image using test-environment values
	TARGET_ENV=test $(MAKE) publish-image

manual-deploy-test: ## (custom,image) deploys the stack using test-environment values
	TARGET_ENV=test $(MAKE) deploy

manual-undeploy-test: ## (custom,image) undeploys the stack using test-environment values
	TARGET_ENV=test $(MAKE) undeploy
