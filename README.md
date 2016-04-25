# vagrant-service-manager

<!-- MarkdownTOC -->

- [Objective](#objective)
- [Usage](#usage)
    - [Example execution of the plugin](#example-execution-of-the-plugin)
    - [Available commands](#available-commands)
    - [Exit codes](#exit-codes)
    - [IP address detection](#ip-address-detection)
- [Development](#development)
    - [Setup](#setup)
    - [Acceptance tests](#acceptance-tests)
    - [Builds](#builds)
- [Getting involved](#getting-involved)

<!-- /MarkdownTOC -->


<a name="objective"></a>
# Objective
The vagrant-service-manager plugin is designed to enable easier access to the features and services provided by the [Atomic Developer Bundle (ADB)](https://github.com/projectatomic/adb-atomic-developer-bundle). It provides setup information, including environment variables and certificates, required to access services provided by the ADB and is a must have for most ADB users.

This plugin makes it easier to use the ADB with host-based tools such as Eclipse and the docker and kubernetes CLI commands. Details on how to use ADB with this plugin can be found in the [ADB Documentation](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/using.rst).

<a name="usage"></a>
# Usage

<a name="example-execution-of-the-plugin"></a>
## Example execution of the plugin

1. Install vagrant-service-manager plugin:

        vagrant plugin install vagrant-service-manager

2. Download the relevant Vagrantfile for your [ADB](https://github.com/projectatomic/adb-atomic-developer-bundle) vagrant box, from the [repository](https://github.com/projectatomic/adb-atomic-developer-bundle/tree/master/components/centos). For further details on the usage of custom Vagrantfiles designed for specific use cases, refer to the [Usage Documentation](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/using.rst).

3. Start the ADB vagrant box using `vagrant up`. For detailed instructions consult the
[Installation Documentation](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/installing.rst).

	**Note:** When the vagrant-service-manager plugin is loaded and a box is started using the VirtualBox provider, the user needs to add a routable non NAT network interface declaration in the Vagrantfile. If the user does not provide a network declaration in the Vagrantfile, a private DHCP network is added by default and a warning is displayed.

4. Run the plugin to get environment variables and certificates:

        $ vagrant service-manager env docker
        # Set the following environment variables to enable access to the
        # docker daemon running inside of the vagrant virtual machine:
        export DOCKER_HOST=tcp://172.28.128.4:2376
        export DOCKER_CERT_PATH=/foo/bar/.vagrant/machines/default/virtualbox/docker
        export DOCKER_TLS_VERIFY=1
        export DOCKER_API_VERSION=1.21
        # run following command to configure your shell:
        # eval "$(vagrant service-manager env docker)"

	**Note:** The required TLS certificates are copied to the host machine at the time of `vagrant up` itself. Every run of `vagrant service-manager env docker` checks for the validity of the certificates on the host machine by matching the certificates inside the box. If the certificates on the host machine are invalid, this command will also re-download the certificates onto the host machine.


<a name="available-commands"></a>
## Available commands

The following table lists the available commands for the plugin and their explanation:

Commands                                                   | Explanations
-----------------------------------------------------------|-----------------------------------------
`vagrant service-manager env`                              | Displays connection information for all active providers in the box.
`vagrant service-manager env docker`                       | Displays connection information for the Docker provider.
`vagrant service-manager env openshift [--script-readable]`| Displays connection information for the OpenShift provider. This is optionally available in script readable format too.
`vagrant service-manager box version [--script-readable]`  | Displays the version and release of the running Vagrant box. This is optionally available in script readable format too.


<a name="exit-codes"></a>
## Exit codes

The following table lists the plugin's exit codes and their meaning:

Exit Code Number   | Meaning
-------------------|-------------------------------------------------------------------------
`0`                | No error
`1`                | Catch all for general errors / Wrong sub-command or option given
`3`                | Vagrant box is not running and should be running for this command to succeed
`126`              | A service inside the box is not running / Command invoked cannot execute


<a name="ip-address-detection"></a>
## IP address detection

There is no standardized way of detecting Vagrant box IP addresses.
This code uses the last IPv4 address available from the set of configured addresses that are *up*.  i.e. if eth0, eth1, and eth2 are all up and have IPv4 addresses, the address on eth2 is used.


<a name="development"></a>
# Development

<a name="setup"></a>
## Setup

After cloing the repository, install the [Bundler](http://bundler.io/) gem:

    $ gem install bundler

Then setup your project dependencies:

    $ bundle install

The build is driven via rake. All build related tash should be executed in the
Bundler environment, e.g. `bundle exec rake clean`. You can get a list of available
Rake tasks via:

    $ bundle exec rake -T

<a name="acceptance-tests"></a>
## Acceptance tests

The source contains also a set of [vagrant-spec](https://github.com/mitchellh/vagrant-spec) acceptance tests. They can be run via:

    $ export VAGRANT_SPEC_BOX=file://<path to Vagrant box file>
    $ bundle exec rake acceptance

Setting the _VAGRANT_SPEC_BOX_ environment variable is mandatory! Any supported
provider (virutalbox, libvirt) can be used. Per default _virtualbox_ is used.
In order to for example use _libvirt_ run:

    $ bundle exec rake acceptance['libvirt']

<a name="builds"></a>
## Builds

- Gem: https://rubygems.org/gems/vagrant-service-manager
- Copr build: https://copr.fedorainfracloud.org/coprs/nshaikh/vagrant-service-manager/builds/

<a name="getting-involved"></a>
# Getting involved

We welcome your input. You can submit issues or pull requests with respect to
the vagrant-service-manager plugin. Refer to the
[contributing guidelines](https://github.com/projectatomic/vagrant-service-manager/blob/master/CONTRIBUTING.md)
for detailed information on how to contribute to this plugin.

You can contact us on:
  * IRC: #atomic and #nulecule on freenode
  * Mailing List: container-tools@redhat.com
