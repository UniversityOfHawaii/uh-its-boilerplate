#  managing makefile-includes
Most of our Docker projects are using GNU make to provide a consistent way
to record the parameters and invocations we're using to creating and manage
Docker images and stacks across all of the environments we're deploying
into.  Typically, there are 4 environments: dev (the developer's desktop
or laptop machine); ci (continuous integration, which uses Jenkins to invoke
make to run tests inside of Jenkins' Docker container); and test, qa, and
prod (where we use Jenkins to deploy Docker stacks into that environment's
swarm).

The files in this directory are maintained in their own git repository, at
git@github.com:UniversityOfHawaii/makefile-includes.git , which we're
including in other projects as a git subtree -- we're using
https://www.atlassian.com/blog/git/alternatives-to-git-submodule-git-subtree
and
https://developer.atlassian.com/blog/2015/05/the-power-of-git-subtree/
as a guide to using git-subtree.

Note: commits containing changes to these files should be isolated from
commits containing changes to other files (on their own branch, for
example), to simplify the process of integrating them back into the
UH makefile-includes project.

# example git-subtree commands
* In the following examples
  * The `--prefix` argument indicates the path relative to the root of your
  project where the `makefile-includes` files will be/are located
  (e.g. 'make/makefile-includes').
  * The `0.1.0` and `0.2.0` are git tags but could be replaced by another valid
  reference (like a branch name).

## adding the makefile subtree to an existing project
1. create a remote (i.e. local alias) for the subtree repo
```
git remote add --fetch --no-tags makefile-includes git@github.com:UniversityOfHawaii/makefile-includes.git
```
2. Add the subtree repo into 'make/makefile-includes'. Any part of the path that
doesn't exist will be created but the final directory must not exist.
```
git subtree add --prefix make/makefile-includes makefile-includes 0.1.0 --squash -m "Add makefile-includes version 0.1.0"
```
* Note: if you're reading this document in a subfolder in a project other than
the UniversityOfHawaii/makefile-includes project, this step has already been
done.

## updating the local copy of the subtree
### A. using make
To update to the latest release-number-tagged version of makefile-includes:
```
make pull-includes
```
To update to a specific released version, e.g. `0.2.0`:
```
MFI_TAG=0.2.0 make pull-includes
```
### B. manually
1. fetch changes from the subtree's repo
```
git fetch --no-tags makefile-includes
```
2. pull changes from a specific tag in that repo, e.g. `0.2.0`
```
git subtree pull --prefix make/makefile-includes makefile-includes 0.2.0 --squash -m "Update makefile-includes to version 0.2.0"
```

## contributing local changes back upstream
1. make your changes to the local `makefile-includes` files directly in your own
project
2. commit those changes to your project (isolating `makefile-includes` changes
  from changes to your own project files into their own branch is best)
### A. using make
3. invoke push-includes, entering the name for the (new) remote branch when prompted
```
make push-includes
```
### B. manually
3. push your changes to the `my-new-feature` branch of the `makefile-includes`
repository
```
git subtree push --prefix make/makefile-includes makefile-includes my-new-feature
```

Either way, you now have a standard branch in 'makefile-includes` you can do a PR, merge,
and tag to release through the GitHub web UI.
