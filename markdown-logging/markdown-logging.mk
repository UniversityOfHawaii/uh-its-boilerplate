UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	MARKDOWN_LOGGER = mdv-linux
endif
ifeq ($(UNAME_S),Darwin)
	MARKDOWN_LOGGER = mdv-mac
endif

ifndef MARKDOWN_LOGGER
$(error Could not configure a markdown logging binary from "uname -s" : '$(UNAME_S)')
endif

MARKDOWN_THEME ?= uh

# Get a path to the markdown-logging files to reference the binary files from
lastItem = $(if $(firstword $1),$(word $(words $1),$1))
markdownLoggingDir := $(dir $(call lastItem,$(MAKEFILE_LIST)))

# $(1): The message to log.
define logmd
	@echo $(1) | $(markdownLoggingDir)bin/$(MARKDOWN_LOGGER) -t $(MARKDOWN_THEME) -
endef
