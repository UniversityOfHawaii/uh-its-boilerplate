# subtree remote name
MFI_REMOTE?=makefile-includes
# subtree prefix (path from project root)
MFI_PREFIX?=make/makefile-includes
# subtree tag or branch to merge
MFI_TAG?=latest

# assumption: only releases will have tags in the format '^\d+.\d+.\d+$'
findLatestRemoteTag=git ls-remote --tags $(MFI_REMOTE) | awk -F/ '{print $$3}' | grep -E '^[0-9]+.[0-9]+.[0-9]+$$' | sort -rn | head -1

pull-includes: ##2 (subtree) updates the makefile-includes subtree to the latest release
	git fetch --no-tags $(MFI_REMOTE)
ifeq ($(MFI_TAG),latest)
	$(eval MFI_TAG := $(shell $(findLatestRemoteTag)))
endif
	git subtree pull --prefix $(MFI_PREFIX) $(MFI_REMOTE) $(MFI_TAG) --squash -m "Updating makefile-includes subtree to version $(MFI_TAG)"

push-includes: ##2 (subtree) pushes changes to the makefile-includes subtree to a new remote branch
	$(eval MFI_NEW_BRANCH := $(shell read -p "Enter new remote branch name: " branchName; echo $$branchName))
	git subtree push --prefix $(MFI_PREFIX) $(MFI_REMOTE) $(MFI_NEW_BRANCH)
	@echo "Created branch $(MFI_NEW_BRANCH) in makefile-includes repo"
