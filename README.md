# vagrant-service-manager

Provides setup information, including environment variables and certificates, required to access services provided by an [Atomic Developer Bundle (ADB)](https://github.com/projectatomic/adb-atomic-developer-bundle).  This plugin makes it easier to use the ADB with host-based tools such as Eclipse and the docker and kubernetes CLI commands.  Details on this usage pattern can be found in the [ADB Documentation](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/using.rst).

##Objective

* To provide the user a CLI to configure the [ADB](https://github.com/projectatomic/adb-atomic-developer-bundle) for different use cases and to provide glue between ADB and the user's development environment.

*  Provide users a tool to control and configure the ADB from the developer's workstation without having to `ssh` into it.

The [Atomic Developer Bundle](https://github.com/projectatomic/adb-atomic-developer-bundle) is  Vagrant box that provides a ready-to-use development environment for container applications. With ADB, developers can dive right into producing complex, multi-container applications.

## Quick Start

1. Install `vagrant-service-manager` plugin

        vagrant plugin install vagrant-service-manager

2. Get the [Vagrantfile](Vagrantfile) and start the ADB using `vagrant up`. [More](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/installing.rst) documentation on setting up ADB.

3. Run the plugin to get environment variables and certificates

        # Copying TLS certificates to /home/nshaikh/vagrant/adb1.7/.vagrant/machines/default/virtualbox/docker
        # Set the following environment variables to enable access to the
        # docker daemon running inside of the vagrant virtual machine:
        export DOCKER_HOST=tcp://172.28.128.4:2376
        export DOCKER_CERT_PATH=/home/nshaikh/vagrant/adb1.7/.vagrant/machines/default/virtualbox/docker
        export DOCKER_TLS_VERIFY=1
        export DOCKER_MACHINE_NAME=868622f
        # run following command to configure your shell:
        # eval "$(vagrant service-manager env docker)"

4. Begin using your host-based tools.

## Get Involved/Contact Us

  * IRC: #atomic and #nulecule on freenode
  * Mailing List: container-tools@redhat.com

## How to Develop/Test

1. Install the Atomic Developer Bundle (ADB), as [documented](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/installing.rst) in the ADB project.  Do not start the box yet.

2. Run `bundle install`

3. Start the box with `bundle exec vagrant up`

4. Develop.  You can test the command by running `bundle exec vagrant service-manager`

5. When you are ready to build the release, get a maintainer to:

  1. Put the gemfile in pkg/ with `rake build`

  2. Increment the Version Number

  3. Release the plugin with `rake release`

  4. Tag the release commit with a vX.Y.Z tag

  5. Create a Github release

###How to build the Vagrant plugin using Bundler

You can also use Bundler to build the plugin and install it manually in your Vagrant environment

```
git clone this repository and run below commands inside the repository

1. bundle install
2. bundle exec rake build

You can install the plugin using `vagrant install pkg/<gem name>` command.
````

## Builds

- Gemfile: https://rubygems.org/gems/vagrant-service-manager

- copr build: https://copr.fedorainfracloud.org/coprs/nshaikh/vagrant-service-manager/builds/
