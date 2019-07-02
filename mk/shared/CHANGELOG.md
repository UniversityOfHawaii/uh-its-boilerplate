# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2019-06-21
### Changed
##### **docker.mk**
  - **Breaking Change:** The `DOCKER_TOOLS_COMMAND` has been updated to avoid using `--userns host`. When running
  outside of Jenkins (on a developer machine), direct access to the unix socket is used. When running in a Jenkins
  job, the tcp socket is used and the `DOCKER_HOST` variable needs to be set in the Jenkins job. From this point
  forward, the `DOCKER_TOOLS_COMMAND` will no longer work on the docci Jenkins.

##### **docker-deploy.mk**
  - The `wait-for-stack` and `wait-for-undeploy` targets have been updated to use the `DOCKER_TOOLS_COMMAND` variable
  instead of directly running docker-tools with `docker run...`.

## [0.3.5] - 2019-06-5
### Added
##### **docker-deploy.mk**
  - Added the ability to configure the number of checks and the time in seconds between checks for
  the `wait-for-deploy*` targets. To override, set the following variables:
  - `STACK_HEALTH_TIMES_TO_CHECK`
  - `STACK_HEALTH_SECONDS_BETWEEN_CHECKS`

### Changed
##### **markdown-logging/markdown-logging.mk**
  - Changed the name of the default theme to `uh`.
  - Move the documentation to a localized README.md and added examples.
  - Removed the quotes from the echo in `logmd` to add flexibility.
  - Switched the h2 & h3 colors which also affects the emphasis and strong emphasis.


## [0.3.4] - 2019-05-31
### Added
- Added `markdown-logging/markdown-logging.mk` which provides a `logmd` function
to log messages to the console in markdown format. Example:
  ```Makefile
    include markdown-logging/markdown-logging.mk
    test:
    	$(call logmd,# This is a header)
  ```
  Themes are defined in [markdown-logging/bin/ansi_tables.json](markdown-logging/bin/ansi_tables.json). The default
  theme used is `960.847`. Other themes can used by overriding the `MARKDOWN_THEME` variable. Setting it to 'random'
  will choose a random theme. Example:
  ```Makefile
    include markdown-logging/markdown-logging.mk
    MARKDOWN_THEME = 799.3706
    test:
      $(call logmd,# This is a header)
  ```

## [0.3.3] - 2019-05-09
### Added
- Added `docker-backup.mk` which includes function definitions to make moving
  files around the swarm with rsync easier. See the comments in that file for
  examples.

## [0.3.2] - 2019-05-02
### Changed
##### docker-deploy.mk
- The shared docker deploy makefile logic has been simplified.  The ability to override
  the set of files has been removed since the whole target can easily be replaced
  in the individual projects. Both DEV and TEST deployments use the file
  `docker-compose/dev-test.yml` and both QA and PROD use `docker-compose/qa-prod.yml`.

## [0.3.1] - 2019-04-16
### Added
- Added the optional `docker-deploy.mk` file to share common docker deployment
  targets. Default paths and filenames are provided for deploy files, but they
  can be overridden.

## [0.3.0] - 2019-04-5
### Added
- Added a way to customize the help column sizes. Example:
  ```makefile
  include make/makefile-includes/common.mk

  HELP_COLUMN_ONE_SIZE = 30
  HELP_COLUMN_TWO_SIZE = 20
  ```

### Removed
- Breaking Change: Stopped setting the `buildConfig` so projects shouldn't
  set `devBuildConfig` and `ciBuildConfig` anymore. Build targets should just
  include a build file as needed and can use `ifdef JENKINS_HOME` if the
  inclusion is shared between multiple build environments.

## [0.2.6] - 2019-03-19
### Added
- added `list-targets`, which lists all targets in the Makefile and its
includes

### Changed
- changed category for `help` and other `targets` from `misc` to `help`
- added categories to `debug-common`, `pull-includes`, and `push-includes` help

### Removed
- deleted `blue` color everywhere because it's practically invisible on dark
backgrounds

## [0.2.5] - 2019-03-13
### Changed
- Added matching `--no-tags` parameter to the `git fetch makefile-includes`
invocation in the README, and removed it from `git subtree pull`

## [0.2.4] - 2019-03-13
### Changed
- Added `--no-tags` parameter to the `git remote add` invocation in the
README, to similarly prevent remote tags from being recreated locally

## [0.2.3] - 2019-03-13
### Changed
- Added `--no-tags` parameter to pull-includes' invocation of `git fetch`,
since there should be no need to have those tags here (and pulling those
tags will collide with the client's own use of version-numbered tags)

## [0.2.2] - 2019-03-13
### Added
- Include file `subtree.mk` which defines targets and variables to
simplify using git-subtree to import changes from/push changes to
makefile-includes
- Make target `pull-includes`, which imports changes from the
makefile-includes repo and merges them into the local subtree.
  - Specify a version tag by setting the environment variable MFI_TAG, e.g.
```
MFI_TAG=0.2.1 make pull-includes
```
- Make target `push-includes``, which creates a new branch in the
makefile-includes remote from the current local branch.  When invoked,
prompts for the name of the remote branch which will be created.

### Changed
- Added help documentation to `debug-common` target in `docker.mk` include

## [0.2.1] - 2019-03-13
### Changed
- Changed release notes to follow https://keepachangelog.com/en/1.0.0/

## [0.2.0] - 2019-03-11
### Changed
Changed the file layout -- including common.mk now automatically brings in all
the rest of the files, and the color constants and docker-specific rules are
separated out to simplify maintenance.

## [0.1.2] - 2019-03-11
### Changed
- Update the readme about how to contribute changes back to this project.

## [0.1.1] - 2019-03-11
### Changed
- Add some clarity to the documentation.

## [0.1.0] - 2019-03-11
### Added
- This initial release includes the original makefiles with some documentation.
