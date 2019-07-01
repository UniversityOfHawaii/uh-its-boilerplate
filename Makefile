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

imageIds:=$(shell sh/localImageExists.sh $(IMAGE_NAME))
clean-dev-image:
ifneq ($(imageIds),)
	@docker image rm $(imageIds)
endif

dev-image-exists:
	@sh/localImageExists.sh $(IMAGE_NAME) >& /dev/null || (printf "dev image %s does not exist\n" $(IMAGE_NAME) && exit 1)

deploy-dev: dev-image-exists ## (custom,image) deploys the dev stack
	@sh/dcompose.sh $(DEV_COMPOSE_COMMON) config | docker stack deploy -c - $(STACK_NAME)
	@sh/stackIsUp.sh $(STACK_NAME)

undeploy-dev: ## (custom,image) undeploys the dev stack
	@docker stack rm $(STACK_NAME)
	@(docker network rm $(shell docker network ls -q --filter Name=$(PROJECT_NAME)) 1>/dev/null 2>&1 || true)
	@sh/stackIsDown.sh $(STACK_NAME)

build-test-image: ## (custom,image) publishes the image (forcibly sets REGISTRY to QA)
	@sh/dcompose.sh $(DEV_COMPOSE_COMMON) -r registry-qa.pvt.hawaii.edu/ build

publish-test-image: ## (custom,image) publishes the image (forcibly sets REGISTRY to QA)
	@sh/dcompose.sh $(DEV_COMPOSE_COMMON) -r registry-qa.pvt.hawaii.edu/ push $(SERVICE_NAME)
