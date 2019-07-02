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
STACK_NAME := boilerplate

include mk/shared/common.mk

COMPOSE_COMMON := -p $(PROJECT_NAME) -b $(BUILD_VERSION) -r $(REGISTRY)

build-image: ## (custom,image) builds the image
	@sh/dcompose.sh $(COMPOSE_COMMON) -f $(DCFILE) build

publish-image: ## (custom,image) publishes the image
	@sh/dcompose.sh $(COMPOSE_COMMON) -f $(DCFILE) push $(SERVICE_NAME)

deploy: ## (custom,image) deploys the stack
	BUILD_VERSION=$(BUILD_VERSION) docker stack deploy -c $(DCFILE) $(STACK_NAME)
	@sh/stackIsUp.sh $(STACK_NAME)

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
