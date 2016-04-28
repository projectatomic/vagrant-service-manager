# vagrant-service-manager

* [Objective](#objective)
* [Example Execution of the Plugin](#example_execution)
* [Available Commands](#commands)
* [Exit codes](#exit_codes)
* [IP Address Detection](#ip_addr)
* [Getting Involved with the Project](#Contributing)
* [Builds](#builds)


The vagrant-service-manager plugin is designed to enable easier access to the features and services provided by the [Atomic Developer Bundle (ADB)](https://github.com/projectatomic/adb-atomic-developer-bundle). It provides setup information, including environment variables and certificates, required to access services provided by the ADB and is a must have for most ADB users.

This plugin makes it easier to use the ADB with host-based tools such as Eclipse and the docker and kubernetes CLI commands. Details on how to use ADB with this plugin can be found in the [ADB Documentation](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/using.rst).


## Objective <a name="objective"></a>

The [ADB](https://github.com/projectatomic/adb-atomic-developer-bundle) provides a ready-to-use development environment for container applications. With ADB, developers can dive right into producing complex, multi-container applications.

The vagrant-service-manager provides the user with:

* A CLI to configure the ADB for different use cases and to provide an interface between ADB and the user's development environment.
* A tool to control and configure the ADB from the
developer's workstation without having to `ssh` directly into the ADB virtual machine.


## Example Execution of the Plugin <a name="example_execution"></a>

1. Install vagrant-service-manager plugin:
 
        vagrant plugin install vagrant-service-manager

2. Download the relevant Vagrantfile for your [ADB](https://github.com/projectatomic/adb-atomic-developer-bundle) vagrant box, from the [repository](https://github.com/projectatomic/adb-atomic-developer-bundle/tree/master/components/centos). For further details on the usage of custom Vagrantfiles designed for specific use cases, refer to the [Usage Documentation](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/using.rst).

3. Start the ADB vagrant box using `vagrant up`. For detailed instructions consult the [Installation Documentation](https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/docs/installing.rst).

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


## Available Commands <a name="commands"></a>

The following section lists the available commands for the plugin and their explanation:

1. `vagrant service-manager env [service] [--script-readable]` 

   Displays connection information for all active services in the box in a manner that can be evaluated in a shell. If a `service` is specified, only the information for that service is displayed. When `--script-readable` is specified the output is in `key=value` format. The supported services are: Docker; OpenShift.

2. `vagrant service-manager box [command]`

   Displays box related information like release version, IP etc. 

3. `vagrant service-manager box version [--script-readable]`

   Displays the version and release information of the running VM. When `--script-readable` is specified the output is in `key=value` format.

4. `vagrant service-manager box ip` 

   Displays the routable IP address of the running VM. 

5. `vagrant service-manager status [service]` 

   Lists services and their running state. If a `service` is specified only the status of that service is displayed. If no service is provided then only supported orchestrators are reported.

6. `vagrant service-manager restart [service]` 

   Restarts the given service in the box.

7. `vagrant service-manager [command] [--help | -h]`

   Displays the possible commands, options and other relevant information for the vagrant-service-manager plugin. If a `command` is specified, only the help relevant to that command is displayed.



## Exit codes <a name="exit_codes"></a>

The following table lists the plugin's exit codes and their meaning:

Exit Code Number   | Meaning
-------------------|-------------------------------------------------------------------------
`0`                | No error
`1`                | Catch all for general errors / Wrong sub-command or option given
`3`                | Vagrant box is not running and should be running for this command to succeed
`126`              | A service inside the box is not running / Command invoked cannot execute


## IP Address Detection <a name="ip_addr"></a>

There is no standardized way of detecting Vagrant box IP addresses.
This code uses the last IPv4 address available from the set of configured addresses that are *up*.  i.e. if eth0, eth1, and eth2 are all up and have IPv4 addresses, the address on eth2 is used.


## Getting Involved with the Project <a name="Contributing"></a>

We welcome your input. You can submit issues or pull requests with respect to the vagrant-service-manager plugin. Refer to the [contributing guidelines](https://github.com/projectatomic/vagrant-service-manager/blob/master/CONTRIBUTING.md) for detailed information on how to contribute to this plugin.

You can contact us on:
  * IRC: #atomic and #nulecule on freenode
  * Mailing List: container-tools@redhat.com


## Builds <a name="builds"></a>

- Gem: https://rubygems.org/gems/vagrant-service-manager

- Copr build: https://copr.fedorainfracloud.org/coprs/nshaikh/vagrant-service-manager/builds/
