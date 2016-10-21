Feature: Command output from box command
  service-manager should return the correct output from box commands

  Scenario Outline: Boot and execute box commands
    Given box is <box>
    And provider is <provider>
    And a file named "Vagrantfile" with:
    """
    begin
      require 'vagrant-libvirt'
    rescue LoadError
      # NOOP
    end

    Vagrant.configure('2') do |config|
      config.vm.box = '<box>'
      config.vm.box_url = 'file://../../.boxes/<box>-<provider>.box'
      config.vm.network :private_network, ip: '<ip>'
      config.vm.synced_folder '.', '/vagrant', disabled: true
      config.servicemanager.services = 'docker'
    end
    """

    When I run `bundle exec vagrant up --provider <provider>`
    Then the exit status should be 0
    And stdout from "bundle exec vagrant up --provider <provider>" should contain:
    """
    ==> default: Docker service configured successfully...
    """

    ####################################################################################################################
    # BOX command
    ####################################################################################################################
    When I run `bundle exec vagrant service-manager box`
    Then the exit status should be 1
    And stdout from "bundle exec vagrant service-manager box" should contain:
    """
    Usage: vagrant service-manager box <sub-command> [options]

    Sub-Command:
          version    display version and release information about the running VM
          ip         display routable IP address of the running VM

    Options:
          --script-readable  display information in a script readable format
          -h, --help         print this help
    """

    When I successfully run `bundle exec vagrant service-manager box --help`
    Then the exit status should be 0
    And stdout from "bundle exec vagrant service-manager box --help" should contain:
    """
    Usage: vagrant service-manager box <sub-command> [options]

    Sub-Command:
          version    display version and release information about the running VM
          ip         display routable IP address of the running VM

    Options:
          --script-readable  display information in a script readable format
          -h, --help         print this help

    Examples:
          vagrant service-manager box version
          vagrant service-manager box version --script-readable
          vagrant service-manager box ip
          vagrant service-manager box ip --script-readable
    """

    When I successfully run `bundle exec vagrant service-manager box ip`
    Then stdout from "bundle exec vagrant service-manager box ip" should contain "<ip>"

    When I successfully run `bundle exec vagrant service-manager box ip --script-readable`
    Then stdout from "bundle exec vagrant service-manager box ip --script-readable" should contain "IP=<ip>"
    And stdout from "bundle exec vagrant service-manager box ip --script-readable" should be script readable

    ####################################################################################################################
    # ENV command
    ####################################################################################################################
    When I successfully run `bundle exec vagrant service-manager env --help`
    Then the exit status should be 0
    And stdout from "bundle exec vagrant service-manager env --help" should contain:
    """
    Usage: vagrant service-manager env [object] [options]

    Objects:
          docker      display information and environment variables for docker
          openshift   display information and environment variables for openshift
          kubernetes  display information and environment variables for kubernetes

    If OBJECT is omitted, display the information for all active services

    Options:
          --script-readable  display information in a script readable format.
          -h, --help         print this help
    """

    When I successfully run `bundle exec vagrant service-manager env`
    Then stdout from "bundle exec vagrant service-manager env" should be evaluable in a shell

    When I successfully run `bundle exec vagrant service-manager env --script-readable`
    Then stdout from "bundle exec vagrant service-manager env --script-readable" should be script readable

    When I successfully run `bundle exec vagrant service-manager env docker`
    Then stdout from "bundle exec vagrant service-manager env docker" should be evaluable in a shell
    And stdout from "bundle exec vagrant service-manager env docker" should contain "export DOCKER_HOST=tcp://<ip>:2376"
    And stdout from "bundle exec vagrant service-manager env docker" should match /export DOCKER_CERT_PATH=.*\/.vagrant\/machines\/cdk\/virtualbox\/docker/
    And stdout from "bundle exec vagrant service-manager env docker" should contain "export DOCKER_TLS_VERIFY=1"
    And stdout from "bundle exec vagrant service-manager env docker" should match /export DOCKER_API_VERSION=1.2\d/
    And stdout from "bundle exec vagrant service-manager env docker" should match /# eval "\$\(vagrant service-manager env docker\)"/

    When I successfully run `bundle exec vagrant service-manager env docker --script-readable`
    Then stdout from "bundle exec vagrant service-manager env docker --script-readable" should be script readable

    When I run `bundle exec vagrant service-manager env openshift`
    Then the exit status should be 126
    And stderr from "bundle exec vagrant service-manager env openshift" should contain:
    """
    # OpenShift service is not running in the vagrant box.
    """

    When I successfully run `bundle exec vagrant service-manager env --debug`
    Then stdout from "bundle exec vagrant service-manager env --debug" should match /DEBUG command: [ service-manager: env ]/


    ####################################################################################################################
    # INSTALL-CLI command
    ####################################################################################################################
    When I successfully run `bundle exec vagrant service-manager install-cli --help`
    Then the exit status should be 0
    And stdout from "bundle exec vagrant service-manager install-cli --help" should contain:
    """
    Install the client binary for the specified service

    Usage: vagrant service-manager install-cli [service] [options]

    Service:
      A supported service. For example: docker, kubernetes or openshift.

    Options:
          -h, --help            print this help
          --cli-version         binary version to install
          --path                absolute or relative path where to install the binary

    Example:
          vagrant service-manager install-cli docker
    """

    When I run `bundle exec vagrant service-manager install-cli`
    Then the exit status should be 126
    And stdout from "bundle exec vagrant service-manager install-cli" should match /Service name missing/

    When I run `bundle exec vagrant service-manager install-cli docker --cli-version 111.222.333`
    Then the exit status should be 126

    When I run `bundle exec vagrant service-manager install-cli docker`
    Then the exit status should be 0
    And the binary "docker" should be installed
    And the stderr should not contain anything

    When I run `bundle exec vagrant service-manager install-cli docker --cli-version 1.12.1`
    Then the exit status should be 0
    And the binary "docker" of service "docker" should be installed with version "1.12.1"
    And the stderr should not contain anything

    When I evaluate and run `bundle exec vagrant service-manager install-cli docker --path #{ENV['VAGRANT_HOME']}/docker`
    Then the exit status should be 0
    And the binary should be installed in path "#{ENV['VAGRANT_HOME']}/docker"
    And the stderr should not contain anything

    When I evaluate and run `bundle exec vagrant service-manager install-cli docker --path #{ENV['VAGRANT_HOME']}/unknown_dir/docker`
    Then the exit status should be 126
    And stderr from evaluating and running "bundle exec vagrant service-manager install-cli docker --path #{ENV['VAGRANT_HOME']}/unknown_dir/docker" should match /Directory path #{ENV['VAGRANT_HOME']}/unknown_dir is invalid or doesn't exist/

    When I run `bundle exec vagrant service-manager install-cli docker --path /foo/bar/docker`
    Then the exit status should be 126
    And stderr from evaluating and running "bundle exec vagrant service-manager install-cli docker --path /foo/bar/docker" should match /Permission denied @ dir_s_mkdir - /foo/

    ####################################################################################################################
    # START/STOP/STATUS/RESTART command
    ####################################################################################################################
    When I successfully run `bundle exec vagrant service-manager status --help`
    Then the exit status should be 0
    And stdout from "bundle exec vagrant service-manager status --help" should contain:
    """
    Usage: vagrant service-manager status [service] [options]

    Options:
          -h, --help         print this help

    If a service is provided, only that service is reported.
    If no service is provided only supported orchestrators are reported.

    Example:
          vagrant service-manager status openshift
    """

    And I successfully run `bundle exec vagrant service-manager stop --help`
    Then the exit status should be 0
    And stdout from "bundle exec vagrant service-manager stop --help" should contain:
    """
    stops the service

    Usage: vagrant service-manager stop <service> [options]

    Service:
        A service provided by sccli. For example:
         docker, kubernetes, openshift etc

    Options:
          -h, --help         print this help

    Examples:
      vagrant service-manager stop docker
    """

    And I successfully run `bundle exec vagrant service-manager start --help`
    Then the exit status should be 0
    And stdout from "bundle exec vagrant service-manager start --help" should contain:
    """
    starts the service

    Usage: vagrant service-manager start <service> [options]

    Service:
        A service provided by sccli. For example:
         docker, kubernetes, openshift etc

    Options:
          -h, --help         print this help

    Examples:
      vagrant service-manager start docker
    """

    And I successfully run `bundle exec vagrant service-manager restart --help`
    Then the exit status should be 0
    And stdout from "bundle exec vagrant service-manager restart --help" should contain:
    """
    restarts the service

    Usage: vagrant service-manager restart <service> [options]

    Service:
        A service provided by sccli. For example:
         docker, kubernetes, openshift etc

    Options:
          -h, --help         print this help

    Examples:
      vagrant service-manager restart docker
    """

    When I successfully run `bundle exec vagrant service-manager status`
    Then stdout from "bundle exec vagrant service-manager status" should contain "docker - running"
    Then stdout from "bundle exec vagrant service-manager status" should contain "openshift - stopped"
    Then stdout from "bundle exec vagrant service-manager status" should contain "kubernetes - stopped"

    When I successfully run `bundle exec vagrant service-manager status docker`
    Then stdout from "bundle exec vagrant service-manager status" should contain "docker - running"

    When I run `bundle exec vagrant service-manager status abcd`
    Then the exit status should be 126
    And stderr from "bundle exec vagrant service-manager status abcd" should contain:
    """
    Unknown service 'abcd'.
    Supported services are docker, openshift, kubernetes etc.
    """

    When the "docker" service is running
    And I successfully run `bundle exec vagrant service-manager stop docker`
    Then the service "docker" should be stopped

    When the "docker" service is not running
    And I successfully run `bundle exec vagrant service-manager start docker`
    Then the service "docker" should be running

    When the "docker" service is running
    And I successfully run `bundle exec vagrant service-manager restart docker`
    Then the service "docker" should be running
    And have a new pid for "docker" service

    Examples:
      | box   | provider   | ip          |
      | cdk   | virtualbox | 10.10.10.42 |
      | adb   | virtualbox | 10.10.10.42 |
      | cdk   | libvirt    | 10.10.10.42 |
      | adb   | libvirt    | 10.10.10.42 |
