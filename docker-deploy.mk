##
#		Docker Deployments
#		This makefile sets up some common targets for our deployments to various
#		swarms. Default files (including paths) are set here as well as default
#		times for the wait commands, but everything can overridden in individual projects.
##

deploy: ## (deployment) Deploy the stack
	@echo
	@echo "Deploying $(cyan)$(stackName)$(endColor) to $(cyan)DEV$(endColor)"
	@echo
	$(call deploy,$(stackName),--file docker-compose/dev-test.yml)

deploy-test:
	@echo
	@echo "Deploying $(cyan)$(stackName)$(endColor) to $(cyan)TEST$(endColor)"
	@echo "\tRegistry:\t$(cyan)$(REGISTRY)$(endColor)"
	@echo "\tTag:\t\t$(cyan)$(VERSION)$(endColor)"
	@echo
	$(call deploy,$(stackName),--file docker-compose/dev-test.yml,ssh doctest)

deploy-qa:
	@echo
	@echo "Deploying $(cyan)$(stackName)$(endColor) to $(cyan)QA$(endColor)"
	@echo
	$(call deploy,$(stackName),--file docker-compose/qa-prod.yml,ssh docqa)

deploy-prod:
	@echo
	@echo "Deploying $(cyan)$(stackName)$(endColor) to $(red)PROD$(endColor)"
	@echo
	$(call deploy,$(stackName),--file docker-compose/qa-prod.yml,ssh docprod)

# $(1) = The stack name.
# $(2) = All the compose files to include.
# $(3) = (optional) SSH command to use before deploying the stack.
define deploy
	REGISTRY=$(REGISTRY) IMAGE_TAG=$(VERSION) \
	docker-compose \
		--project-name $(PROJECT_NAME) \
		$(2) \
		config \
	| $(3) docker stack deploy -c - $(1)
endef

STACK_HEALTH_TIMES_TO_CHECK = 20
STACK_HEALTH_SECONDS_BETWEEN_CHECKS = 5

wait-for-deploy: ## (deployment) Wait for the stack to get healthy
	$(call wait-for-stack,$(stackName),$(STACK_HEALTH_TIMES_TO_CHECK),$(STACK_HEALTH_SECONDS_BETWEEN_CHECKS))

wait-for-deploy-test:
	ssh doctest \
		$(call wait-for-stack,$(stackName),$(STACK_HEALTH_TIMES_TO_CHECK),$(STACK_HEALTH_SECONDS_BETWEEN_CHECKS))

wait-for-deploy-qa:
	ssh docqa \
		$(call wait-for-stack,$(stackName),$(STACK_HEALTH_TIMES_TO_CHECK),$(STACK_HEALTH_SECONDS_BETWEEN_CHECKS))

wait-for-deploy-prod:
	ssh docprod \
		$(call wait-for-stack,$(stackName),$(STACK_HEALTH_TIMES_TO_CHECK),$(STACK_HEALTH_SECONDS_BETWEEN_CHECKS))

# $(1) = The stack name to wait for.
# $(2) = The number of times to check.
# $(3) = The number of seconds to wait between checks.
define wait-for-stack
	$(DOCKER_TOOLS_COMMAND) node node-scripts/stack-health.js $(1) $(2) $(3)
endef

undeploy: ## (deployment) Undeploy the stack
	@echo
	@echo "Undeploying $(cyan)$(stackName)$(endColor) FROM $(cyan)DEV$(endColor)"
	@echo
	$(call undeploy,$(stackName))

undeploy-test:
	@echo
	@echo "Undeploying $(cyan)$(stackName)$(endColor) FROM $(cyan)TEST$(endColor)"
	@echo
	ssh doctest \
		$(call undeploy,$(stackName))

undeploy-qa:
	@echo
	@echo "Undeploying $(cyan)$(stackName)$(endColor) FROM $(cyan)QA$(endColor)"
	@echo
	ssh docqa \
		$(call undeploy,$(stackName))

undeploy-prod:
	@echo
	@echo "Undeploying $(cyan)$(stackName)$(endColor) FROM $(red)PROD$(endColor)"
	@echo
	ssh docprod \
		$(call undeploy,$(stackName))

# $(1) = The stack name to wait for.
define undeploy
	docker stack rm $(1)
endef

wait-for-undeploy:  ## (deployment) Waits for the stack to undeploy
	$(call wait-for-undeploy,$(stackName))

wait-for-undeploy-test:
	ssh doctest \
		$(call wait-for-undeploy,$(stackName))

wait-for-undeploy-qa:
	ssh docqa \
		$(call wait-for-undeploy,$(stackName))

wait-for-undeploy-prod:
	ssh docprod \
		$(call wait-for-undeploy,$(stackName))

define wait-for-undeploy
	$(DOCKER_TOOLS_COMMAND) node node-scripts/stack-wait.js $(1)
endef
