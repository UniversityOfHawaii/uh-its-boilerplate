################
#
# This function sets up a container that will rsync two local directories.
#
# Note: Since the container doesn't run as root, the destination directory
#       needs to already exist and be writable by the specified user.
#
# $(1) = The ssh command to get to the destination node. It can be empty if
#        your DEV machine is the destination.
# $(2) = The source path (must be a local directory).
# $(3) = The destination path (must be a local directory).
# $(4) = The id of the user that owns the source files.
# $(5) = Any options to send to rsync.
#
# Example Use: Sync /swarm-volumes/project/home to /swarm-volumes/project/backup/home on TEST.
#	The $\ enables the call to span multiple lines for readability without adding
#  a whitespace character to any of the arguments.
#
#		define rsyncOptions
#			--archive --compress --stats
#		endef
#		$(call rsync-from-local,$\
#			ssh doctest,$\
#			/swarm-volumes/project/home,$\
#			/swarm-volumes/project/backup/home,$\
#			$(MY_USER_ID),$\
#			$(rsyncOptions))
#
################
define rsync-from-local
	@echo
	@echo "Syncing"
	@echo "\tFrom: $(cyan)$(2)$(endColor)"
	@echo "\tTo: $(cyan)$(3)$(endColor)"
	@echo
	$(1) \
			docker run --rm \
				--volume $(2):/source \
				--volume $(3):/destination \
				--user $(4) \
			registry.pvt.hawaii.edu/docker-tools:$(DOCKER_TOOLS_VERSION) \
			rsync \
				$(5) \
				/source/ /destination/
endef


################
#
# Rsync a directory from a remote swarm node to your DEV environment.
# $(1) = The remote source path.  This is passed to rsync (use USER@HOST:SRC).
# $(2) = The destination path (must be a local directory).
# $(3) = The id of the user that owns the source files.
# $(4) = Any options to send to rsync.
# $(5) = The path to the ssh key to use for authentication to the remote source from $(2).
#
# Example Use: Sync doctest:/swarm-volumes/project/backup/home to
# env/dev/swarm-volumes/backup/TEST/home onto your DEV machine.
#
#	The $\ enables the call to span multiple lines for readability without adding
#  a whitespace character to any of the arguments.
#
#		define rsyncOptions
#			--archive --compress --stats
#		endef
#		$(call rsync-from-remote-to-DEV,$\
#			$(shell whoami)@doctest:/swarm-volumes/project/backup/home,$\
#			$$(pwd)/env/dev/swarm-volumes/backup/TEST/home,$\
#			$(MY_USER_ID),$\
#			$(rsyncOptions),$\
#			$(MY_TEST_SSH_KEY_PATH))
#
################
define rsync-from-remote-to-DEV
	@echo "$(white)Starting rsync on $(cyan)DEV$(endColor)"
	@echo
	$(call rsync-from-remote,$(1),$(2),$(3),$(4),$(5),,)
endef

################
#
# Rsync a directory from a remote swarm node to the TEST swarm.
# $(1) = The remote source path.  This is passed to rsync (use USER@HOST:SRC).
# $(2) = The destination path (must be a local directory).
# $(3) = The id of the user that owns the source files.
# $(4) = Any options to send to rsync.
# $(5) = The path to the ssh key to use for authentication to the remote source from $(2).
#
# Example Use: Sync docqa:/swarm-volumes/project/backup/home to
# /swarm-volumes/project/backup/QA/home onto the TEST swarm.
#
#	The $\ enables the call to span multiple lines for readability without adding
#  a whitespace character to any of the arguments.
#
#		define rsyncOptions
#			--archive --compress --stats
#		endef
#		$(call rsync-from-remote-to-TEST,$\
#			jenkins@docqa:/swarm-volumes/project/backup/home,$\
#			$$(pwd)/env/dev/swarm-volumes/backup/TEST/home,$\
#			$(MY_USER_ID),$\
#			$(rsyncOptions),$\
#			~/.ssh/id_rsa.qa)
#
################
define rsync-from-remote-to-TEST
@echo "$(white)Starting rsync on $(cyan)TEST$(endColor)"
@echo
	$(call rsync-from-remote,$(1),$(2),$(3),$(4),$(5),ssh -A doctest ',')
endef

################
#
# Rsync a directory from a remote swarm node to the QA swarm.
# $(1) = The remote source path.  This is passed to rsync (use USER@HOST:SRC).
# $(2) = The destination path (must be a local directory).
# $(3) = The id of the user that owns the source files.
# $(4) = Any options to send to rsync.
# $(5) = The path to the ssh key to use for authentication to the remote source from $(2).
#
# Example Use: Sync docprod:/swarm-volumes/project/backup/home to
# /swarm-volumes/project/backup/QA/home onto the QA swarm.
#
#	The $\ enables the call to span multiple lines for readability without adding
#  a whitespace character to any of the arguments.
#
#		define rsyncOptions
#			--archive --compress --stats
#		endef
#		$(call rsync-from-remote-to-QA,$\
#			jenkins@docprod:/swarm-volumes/project/backup/home,$\
#			$$(pwd)/env/dev/swarm-volumes/backup/TEST/home,$\
#			$(MY_USER_ID),$\
#			$(rsyncOptions),$\
#			~/.ssh/id_rsa.prod)
#
################
define rsync-from-remote-to-QA
	@echo "$(white)Starting rsync on $(cyan)QA$(endColor)"
	@echo
	$(call rsync-from-remote,$(1),$(2),$(3),$(4),$(5),ssh -A docqa ',')
endef

################
# Purposefully unimplemented. We don't have a use case for pulling files
# from a remote host onto the PROD swarm.
################
define rsync-from-remote-to-PROD
	@echo "$(red)Purposefully unimplemented for now...$(endColor)"
	@echo
endef

################
#
# This function sets up a container that will rsync a remote source to
# a local one. Most likely you'll want to use one of the swarm specific functions
# instead of this one directly (rsync-from-remote-to-DEV, rsync-from-remote-to-TEST,
# or rsync-from-remote-to-QA).
#
# NOTE: This process requires the container to run in the "host" user-namespace
#       as root, which give access to the real root on the host. The reason is
#       because it needs access to two resource owned by different users.
#       In order to ssh to a remote host, the container needs access to the
#       ssh agent socket which is owned by the user executing the make target.
#       The container user also needs permissions on the files it's syncing.
#
# NOTE: The strange $(5) and $(6) parameter allows us to use this for both
#       DEV as well as remote swarms and not duplicate the long command. I
#       couldn't figure out a way to work around the nested quoting without this.
#       For DEV, the command will look like this:
#           docker run... rsync.. -e "ssh -o ..."
#       For any other swarm, the command will look like this:
#           ssh -A <swarm> 'docker run... rsync.. -e "ssh -o ..."'
#
# $(1) = The remote source path.  This is passed to rsync (use USER@HOST:SRC).
# $(2) = The destination path (must be a local directory).
# $(3) = The id of the user that owns the source files.
# $(4) = Any options to send to rsync.
# $(5) = The path to the ssh key to use for authentication to the remote source from $(2).
# $(6) = If not DEV, the first part of the ssh command which surrounds the rsync
#        command (i.e. ssh -A '). Note: It must end in a single quote, not a double quote.
# $(7) = If not DEV, the closing quote of the ssh command which surrounds the rsync
#        command (i.e. '). Note: It must end in a single quote, not a double quote.

#
################

# Joining the commands with ; ensures they share the same environment and
# that each command will run regardless of the previous commands result.
#
# The `set +e` and `set -e` allows us to always run the ssh-agent even if there
# were errors.
#
define rsync-from-remote
	@echo "Syncing"
	@echo "\tFrom: $(cyan)$(1)$(endColor)"
	@echo "\tTo: $(cyan)$(2)$(endColor)"
	@echo
	eval $$(ssh-agent) ; \
	ssh-add $(5) ; \
	set +e ; \
	$(6) \
			docker run --rm \
				--volume $(2):/destination \
				--volume $$(dirname $$SSH_AUTH_SOCK):$$(dirname $$SSH_AUTH_SOCK) \
				--env SSH_AUTH_SOCK=$$SSH_AUTH_SOCK \
				--user root \
				--userns host \
			registry.pvt.hawaii.edu/docker-tools:$(DOCKER_TOOLS_VERSION) \
			rsync \
				-e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
				--chown $(3):$(3) \
				$(4) \
			$(1)/ /destination$(7) ; \
	exitStatus=$$? ; \
	set -e ; \
	ssh-agent -k ; \
	exit $$exitStatus
endef
