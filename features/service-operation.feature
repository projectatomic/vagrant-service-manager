Feature: Command output from service operations like stop/start/restart
  service-manager should return the correct exit code from stop/start/restart command

  @operation
  Scenario Outline: Boot and execute service operations like stop/start/restart
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
      config.vm.box_url = 'file://../boxes/<box>-<provider>.box'
      config.vm.network :private_network, ip: '<ip>'
      config.vm.synced_folder '.', '/vagrant', disabled: true
      config.servicemanager.services = 'docker'
    end
    """

    When I successfully run `bundle exec vagrant up --provider <provider>`
    And I successfully run `bundle exec vagrant service-manager status --help`
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
    Unkown service 'abcd'.
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
