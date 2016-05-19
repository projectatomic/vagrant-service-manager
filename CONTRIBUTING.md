# Contributing to vagrant-service-manager

<!-- MarkdownTOC -->

- [Submitting issues](#submitting-issues)
- [Submitting pull requests](#submitting-pull-requests)
  - [Get Started](#get-started)
  - [Create a topic branch](#create-a-topic-branch)
  - [Code](#code)
  - [Commit](#commit)
  - [Submit](#submit)
- [Merging pull requests](#merging-pull-requests)

<!-- /MarkdownTOC -->

The following is a set of guidelines for contributing to the
vagrant-service-manager plugin.

These are guidelines, please use your best judgment and feel free to propose
changes to this document.

<a name="submitting-issues"></a>
## Submitting issues

You can submit issues with respect to the vagrant-service-manager plugin [here](https://github.com/projectatomic/vagrant-service-manager/issues/new).
Make sure you include all the relevant details pertaining the issue.

Before submitting a new issue, it is suggested to check the [existing issues](https://github.com/projectatomic/vagrant-service-manager/issues)
in order to avoid duplication. The vagrant-service-manager plugin works closely
with the [Atomic Developer Bundle](https://github.com/projectatomic/adb-atomic-developer-bundle/issues)
and the [adb-utils](https://github.com/projectatomic/adb-utils/issues) RPM.
You may wish to review the issues in both these repositories as well.

<a name="submitting-pull-requests"></a>
## Submitting pull requests

<a name="get-started"></a>
### Get Started

If you are just getting started with Git and GitHub there are a few prerequisite
steps.

* Make sure you have a [GitHub account](https://github.com/signup/free).
* [Fork](https://help.github.com/articles/fork-a-repo/) the
   vagrant-service-manager repository. As discussed in the linked page, this also includes:
    * [Setting up](https://help.github.com/articles/set-up-git) your local git install.
    * Cloning your fork.

<a name="create-a-topic-branch"></a>
### Create a topic branch

Create a [topic branch](http://git-scm.com/book/en/Git-Branching-Branching-Workflows#Topic-Branches)
on which you will work. The convention is to name the branch using the issue key
you are working on. If there is not already an issue covering the work you want
to do, create one (see [submitting issues](#submitting-issues)).
Assuming for example you will be working from the master branch and working on
the GitHub issue 123 : `git checkout -b issue-123 master`

<a name="code"></a>
### Code

Do your work! Refer to the [development](README.md#development) section in the
[README](README.md) to get started.

<a name="commit"></a>
### Commit

* Make commits of logical units.
* Be sure to use the GitHub issue key in the commit message, eg `Issue #123 ...`.
* Make sure you have added the necessary tests for your changes.
* Make sure you have added appropriate documentation updates.
* Run _all_ the tests to assure nothing else was accidentally broken.

<a name="submit"></a>
### Submit

* Push your changes to the topic branch in your fork of the repository.
* Initiate a [pull request](https://help.github.com/articles/using-pull-requests/).
* All changes need at least 2 ACKs from maintainers before they will be merged.
  If the author of the PR is a maintainer, their submission is considered to be
  the first ACK. Therefore, pull requests from maintainers only need one additional ACK. By "2 ACKs" we mean that two maintainers must acknowledge that the change is a good one.

<a name="merging-pull-requests"></a>
## Merging pull requests

A project maintainer will merge the pull request. He should avoid using the
GitHub UI for the merge and prefer merges over the the command line to avoid
merge commits and to keep a linear commit history. Here is an example work-flow
assuming issue 123 from above:

    # Create a local branch for the pull request
    $ git checkout -b issue-123 master

    # Pull the changes
    $ git pull <remote of the pull request> issue-123

    # If necessary rebase changes on master to ensure we have a fast forward.
    $ git rebase -i master

    # If required, update CHANGELOG.md in the unreleased section. Commit!

    # Merge changes into master
    $ git checkout master
    $ git merge issue-123

    # Push to origin
    $ git push origin master
