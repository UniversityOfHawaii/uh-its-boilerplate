#
# include all of the other shared includes
#

## the path to the file currently being processed is the last item in
## MAKEFILE_LIST, so extract and reuse its directory to find its peers
lastItem = $(if $(firstword $1),$(word $(words $1),$1))
commonDir := $(dir $(call lastItem,$(MAKEFILE_LIST)))

include $(commonDir)/colors.mk
include $(commonDir)/docker.mk
include $(commonDir)/help.mk
include $(commonDir)/subtree.mk
