# Controls the help column sizes and can be overridden.
HELP_COLUMN_ONE_SIZE = 20
HELP_COLUMN_TWO_SIZE = 20

.PHONY: help other list-targets

define MAKE_AWK_PROGRAM
{FS = "##2? " }
{
  startGreen="\033[32m";
  startBlue="\033[36m";
  endColor="\033[0m";

  head=substr($$1,1,index($$1,":")-1);
  if (index($$2,"(") > 0) {
    subhead=substr($$2,index($$2,"(")+1,index($$2,")")-2);
    descr=substr($$2,length(subhead)+4);
  } else {
    subhead="";
    descr=$$2;
  }

  head=sprintf("$(cyan)%-$(HELP_COLUMN_ONE_SIZE)s$(endColor)", head);
  subhead=sprintf("$(green)%-$(HELP_COLUMN_TWO_SIZE)s$(endColor)", subhead);
}
# match any line containing a target followed by a double-comment
/^[a-zA-Z_-]+:.*? ##2? /{
	# only print if (primary-comment and not-secondary) or
	# (secondary-comment and secondary)
  if ( (($$0 ~ / ## /) && (secondary != 1)) ||
  	(($$0 ~ / ##2 /) && (secondary == 1)) ) {
		printf "%s %s %s\n", head, subhead, descr;
  }
}
endef
export MAKE_AWK_PROGRAM

help: ## (help) list primary make targets
	$(info -----------------)
	$(info Available targets)
	$(info -----------------)
	@awk -v secondary=0 "$$MAKE_AWK_PROGRAM" $(MAKEFILE_LIST)

# more complex because I want to display 'none' if none are defined
SECONDARY_COUNT=$(strip $(shell grep "\#\#2" $(MAKEFILE_LIST) | wc -l))
other: ## (help) list secondary make targets (if any)
	$(info -----------------)
	$(info Secondary targets)
	$(info -----------------)
ifeq ($(SECONDARY_COUNT),"0")
	@echo "(none)"
else
	@awk -v secondary=1 "$$MAKE_AWK_PROGRAM" $(MAKEFILE_LIST)
endif

define LIST_TARGETS_AWK
{FS = ":" }
/^[a-zA-Z0-9-]*:/ {
  split($$1,A,/ /);for(i in A)print A[i]
}
endef
export LIST_TARGETS_AWK
list-targets: ## (help) lists all targets available in the current Makefile and its includes
	@$(MAKE) -n -p help 2>&1 | awk "$$LIST_TARGETS_AWK" | grep -v '^Makefile$$' | grep -v '__\$$' | sort
