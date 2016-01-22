# vagrant-adbinfo Vagrant Plugin

Provide setup information, including environment variables and certificates, required to access services provided by an [Atomic Developer Bundle (ADB)](https://github.com/projectatomic/adb-atomic-developer-bundle).  This plugin makes it easier to use the ADB with host-based tools such as Eclipse and the docker and kubernetes CLI commands.  Details on this usage pattern can be found in the [ADB Documentation](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/using.rst).

The [Atomic Developer Bundle](https://github.com/projectatomic/adb-atomic-developer-bundle) is  Vagrant box that provides a ready-to-use development environment for container applications. With ADB, developers can dive right into producing complex, multi-container applications.

## Quick Start

1. Install and start the Atomic Developer Bundle (ADB), as [documented](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/installing.rst) in the ADB project.

2. Install the vagrant-adbinfo plugin

        vagrant plugin install vagrant-adbinfo

3. Run the plugin to get environment variables and certificates

        $ vagrant adbinfo
        Set the following environment variables to enable access to the
        docker daemon running inside of the vagrant virtual machine:

        export DOCKER_HOST=tcp://172.13.14.1:5555
        export DOCKER_CERT_PATH=/home/bexelbie/Repositories/vagrant-adbinfo/.vagrant/machines/default/virtualbox/.docker
        export DOCKER_TLS_VERIFY=1
        export DOCKER_MACHINE_NAME="90d3e96"

4. Begin using your host-based tools.

## Get Involved/Contact Us

  * IRC: #atomic and #nulecule on freenode
  * Mailing List: container-tools@redhat.com

## How to Develop/Test

1. Install the Atomic Developer Bundle (ADB), as [documented](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/installing.rst) in the ADB project.  Do not start the box yet.

2. Run `bundle install`

3. Start the box with `bundle exec vagrant up`

4. Develop.  You can test the command by running `bundle exec vagrant adbinfo`

5. When you are ready to build the release, get a maintainer to:

  1. Put the gemfile in pkg/ with `rake build`

  2. Increment the Version Number

  3. Release the plugin with `rake release`

  4. Tag the release commit with a vX.Y.Z tag

  5. Create a Github release
