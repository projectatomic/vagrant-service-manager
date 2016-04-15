# Contributing to vagrant-service-manager Plugin

The following is a set of guidelines for contributing to the
vagrant-service-manager plugin, which is hosted in the [Project Atomic
Organization](https://github.com/projectatomic) on GitHub.

These are just guidelines, please use your best judgement and feel free
to propose changes to this document in a pull request.

At this point, this document is not complete, but as decisions are made on the
[container-tools@redhat.com](https://www.redhat.com/mailman/listinfo/container-tools)
mailing list they will be added to this document.


## Submitting Issues

You can submit issues with respect to the vagrant-service-manager plugin [here](https://github.com/projectatomic/vagrant-service-manager/issues/new).Make sure you include all the relevant details pertaining the issue.

Before submitting new issues, it is suggested to check [all existing issues](https://github.com/projectatomic/vagrant-service-manager/issues) in order to avoid duplication.The vagrant-service-manager plugin works closely with the [ADB](https://github.com/projectatomic/adb-atomic-developer-bundle/issues) and the [adb-utils](https://github.com/projectatomic/adb-utils/issues) RPM. You may wish to review the issues in both the repositories as well.


## Submitting Pull Requests

* All changes will be made by pull request (PR), even from core
  committers/maintainers.

* All changes must include appropriate documentation updates.

* All changes must include an entry in the [Changelog document](https://github.com/projectatomic/vagrant-service-manager/blob/master/CHANGELOG.md) in the *Unreleased* section describing the change. Your new entry should be the last entry in the *Unreleased* section and should include your GitHub userid.

* All changes need at least 2 ACKs from maintainers before they will be merged. If
  the author of the PR is a maintainer, their submission is considered
  to be the first ACK.  Therefore, PRs from maintainers only need one
  additional ACK.

  By "2 ACKs" we mean that two maintainers must acknowledge that the change
  is a good one. The 2<sup>nd</sup> person to ACK the PR should merge the PR with
  a comment including their agreement.


## How to Develop/Test

1. Install the Atomic Developer Bundle (ADB), as
[documented](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/installing.rst)
in the ADB project.  Do not start the box yet.

2. Fork and clone the vagrant-service-manager repository

        git clone https://github.com/projectatomic/vagrant-service-manager

3. Change the directory to vagrant-service-manager `cd vagrant-service-manager`

4. Run `bundle install`

5. Start the box with `bundle exec vagrant up

6. Develop the plugin and test by running `bundle exec vagrant service-manager`

7. When you are ready to build the release, get one of the [repository maintainers](https://github.com/projectatomic/vagrant-service-manager/blob/master/MAINTAINERS) to release the plugin.


### How to build the Vagrant plugin using Bundler

You can also use Bundler to build the plugin and install it manually in
your Vagrant environment

1. Run the commands below inside of the repository:

```
$ bundle install
$ bundle exec rake build
````

2. Install the plugin using:

    vagrant plugin install pkg/<gem name>

