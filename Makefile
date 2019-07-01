.DEFAULT_GOAL := help
##
# External environment variables, set in the Jenkinsfile
#   BUILD_VERSION = releaseDataFromGit.versionFromGitStatus()
#   REGISTRY = releaseDataFromGit.registryFromGitStatus()
##

## default values for dev
REGISTRY ?= ""
BUILD_VERSION ?= SNAPSHOT

PROJECT_NAME := uh-its-boilerplate
SERVICE_NAME := server
STACK_NAME := boilerplate
IMAGE_NAME := $(PROJECT_NAME):$(BUILD_VERSION)

include mk/shared/common.mk

COMPOSE_COMMON := -p $(PROJECT_NAME) -b $(BUILD_VERSION) -i $(IMAGE_NAME) -r $(REGISTRY)
DEV_COMPOSE_COMMON := $(COMPOSE_COMMON) -f docker-compose/dev-test.yml

build-image: ## (custom,image) builds the image
	@sh/dcompose.sh $(DEV_COMPOSE_COMMON) build

publish-image: ## (custom,image) publishes the image
	@sh/dcompose.sh $(DEV_COMPOSE_COMMON) push $(SERVICE_NAME)

deploy: ## (custom,image) deploys the stack
	BUILD_VERSION=$(BUILD_VERSION) IMAGE_NAME=$(IMAGE_NAME) docker stack deploy -c docker-compose/dev-test.yml $(STACK_NAME)
	@sh/stackIsUp.sh $(STACK_NAME)

undeploy: ## (custom,image) undeploys the stack
	@docker stack rm $(STACK_NAME)
	@(docker network rm $(shell docker network ls -q --filter Name=$(PROJECT_NAME)) 1>/dev/null 2>&1 || true)
	@sh/stackIsDown.sh $(STACK_NAME)

build-test-image: ## (custom,image) publishes the image (forcibly sets REGISTRY to QA)
	$(MAKE) REGISTRY=registry-qa.pvt.hawaii.edu/ build-image

publish-test-image: ## (custom,image) publishes the image (forcibly sets REGISTRY to QA)
	$(MAKE) REGISTRY=registry-qa.pvt.hawaii.edu/ publish-image

deploy-test: ## (custom,image) deploys the stack in test
	$(MAKE) REGISTRY=registry-qa.pvt.hawaii.edu/ deploy

undeploy-test: ## (custom,image) undeploys the stack in test
	$(MAKE) REGISTRY=registry-qa.pvt.hawaii.edu/ undeploy
