Feature: Command behavior of client side tools installation
  service-manager should correctly verify behavior of install-cli command

  @install_cli
  Scenario Outline: Boot and install client side tools
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

    When I successfully run `bundle exec vagrant up --provider <provider>`
    And I successfully run `bundle exec vagrant service-manager install-cli --help`
    Then the exit status should be 0
    And stdout from "bundle exec vagrant service-manager install-cli --help" should contain:
    """
    Install the client binary for the specified service

    Usage: vagrant service-manager install-cli [service] [options]

    Service:
      A supported service. For example: docker, kubernetes or openshift.

    Options:
          -h, --help         print this help

    Example:
          vagrant service-manager install-cli docker
    """

    When I run `bundle exec vagrant service-manager install-cli`
    Then the exit status should be 126
    And stdout from "bundle exec vagrant service-manager install-cli" should match /Service name missing/

    When I run `bundle exec vagrant service-manager install-cli docker --cli-version 111.222.333`
    Then the exit status should be 126

    When I run `bundle exec vagrant service-manager install-cli docker`
    And box is "adb"
    Then the exit status should be 0
    And the binary for "docker" with version "1.9.1" should be installed

    When I run `bundle exec vagrant service-manager install-cli docker`
    And box is "cdk"
    Then the exit status should be 126
    And stdout from "bundle exec vagrant service-manager install-cli docker" should contain:
    """
    The CDK does not support client binary installs via the 'install-cli' command.
    Please visit access.redhat.com to download client binaries.
    """

    Examples:
      | box   | provider   | ip          |
      | cdk   | virtualbox | 10.10.10.42 |
      | adb   | virtualbox | 10.10.10.42 |
      | cdk   | libvirt    | 10.10.10.42 |
      | adb   | libvirt    | 10.10.10.42 |
