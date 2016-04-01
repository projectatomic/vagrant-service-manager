# vagrant-service-manager

* [Objective](#objective)
* [Quick Start](#quick_start)
* [Exit codes](#exit_codes)
* [IP Address Detection](#ip_addr)
* [Get Involved/Contact Us](#involved)
* [How to Develop/Test](#develop)
  * [How to build the Vagrant plugin using Bundler](#bundler)
* [Builds](#builds)


The vagrant-service-manager plugin is designed to enable easier access to the features and services provided by the [Atomic Developer Bundle (ADB)](https://github.com/projectatomic/adb-atomic-developer-bundle). It provides setup information, including environment variables and certificates, required to access services provided by the ADB and is a must have for most ADB users.

This plugin makes it easier to use the ADB with host-based tools such as Eclipse and the docker and kubernetes CLI commands. Details on how to use ADB with this plugin can be found in the [ADB Documentation](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/using.rst).


## Objective <a name="objective"></a>

The [ADB](https://github.com/projectatomic/adb-atomic-developer-bundle) provides a ready-to-use development environment for container applications. With ADB, developers can dive right into producing complex, multi-container applications.

The vagrant-service-manager provides the user with:

* A CLI to configure the ADB for different use cases and to provide an interface between ADB and the user's development environment.
* A tool to control and configure the ADB from the
developer's workstation without having to `ssh` directly into the ADB virtual machine.


## Example execution of the plugin

1. Install vagrant-service-manager plugin:

        vagrant plugin install vagrant-service-manager

2. Get a Vagrantfile for your box of choice. Users of the
[ADB](https://github.com/projectatomic/adb-atomic-developer-bundle) should download the relevant [Vagrantfile from the repository](https://github.com/projectatomic/adb-atomic-developer-bundle/tree/master/components/centos). For further details and to use custom vagrant files designed for specific use cases, refer to the [usage documentation](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/using.rst).

3. Start the vagrant box or ADB using `vagrant up`. For detailed instructions consult the
[Installation Documentation](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/installing.rst).

	**Note:** When the vagrant-service-manager plugin is loaded and a box is started using the VirtualBox provider, the user needs to add a routable non NAT network interface declaration in the Vagrantfile. If the user does not provide a network declaration in the Vagrantfile, a private DHCP network is added by default and a warning is displayed.

4. Run the plugin to get environment variables and certificates:

        $ vagrant service-manager env docker

        # Copying TLS certificates to /home/nshaikh/vagrant/adb1.7/.vagrant/machines/default/virtualbox/docker
        # Set the following environment variables to enable access to the
        # docker daemon running inside of the vagrant virtual machine:
        export DOCKER_HOST=tcp://172.28.128.4:2376
        export DOCKER_CERT_PATH=/home/nshaikh/vagrant/adb1.7/.vagrant/machines/default/virtualbox/docker
        export DOCKER_TLS_VERIFY=1
        export DOCKER_MACHINE_NAME=868622f
        # run following command to configure your shell:
        # eval "$(vagrant service-manager env docker)"

	**Note:** The required TLS certificates are copied to the host machine at the time of `vagrant up` itself. Every run of `vagrant service-manager env docker` checks for the validity of the certificates on the host machine by matching the certificates inside the box. If the certificates on the host machine are invalid, this command will also re-download the certificates onto the host machine.


## Available commands

The following table lists the available commands for the plugin and their explanation:

Commands                                                   | Explanations
-----------------------------------------------------------|-----------------------------------------
`vagrant service-manager env`                              | Displays connection information for all active providers in the box.
`vagrant service-manager env docker`                       | Displays connection information for the Docker provider.
`vagrant service-manager env openshift` [--script-readable]| Displays connection information for the OpenShift provider. This is optionally available in script readable format too.
`vagrant service-manager box version` [--script-readable]  | Displays the version and release of the running Vagrant box. This is optionally available in script readable format too.


## Exit codes <a name="exit_codes"></a>

The following table lists the plugin's exit codes and their meaning:

Exit Code Number   | Meaning
-------------------|-------------------------------------------------------------------------
`0`                | No error
`1`                | Catch all for general errors / Wrong sub-command or option given
`3`                | Vagrant box is not running and should be running for this command to succeed
`126`              | A service inside the box is not running / Command invoked cannot execute


## IP Address Detection <a name="ip_addr"></a>

There is no standarized way of detection Vagrant box IP addresses.
This code uses the last IPv4 address available from the set of configured
addresses that are *up*.  i.e. if eth0, eth1, and eth2 are all up and
have IPv4 addresses, the address on eth2 is used.


## Getting involved with the project

We welcome your input. Refer to the [contributing guidelines](https://github.com/projectatomic/vagrant-service-manager/blob/master/CONTRIBUTING.md) for information on how to contribute to this plugin.

You can contact us on:
  * IRC: #atomic and #nulecule on freenode
  * Mailing List: container-tools@redhat.com


## Builds <a name="builds"></a>

- Gem: https://rubygems.org/gems/vagrant-service-manager

- Copr build: https://copr.fedorainfracloud.org/coprs/nshaikh/vagrant-service-manager/builds/
