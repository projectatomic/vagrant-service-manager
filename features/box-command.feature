Feature: Command output from box command
  service-manager should return the correct output from box commands

  @box
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

    When I successfully run `bundle exec vagrant up --provider <provider>`
    And I run `bundle exec vagrant service-manager box`
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

    Examples:
      | box   | provider   | ip          |
      | cdk   | virtualbox | 10.10.10.42 |
      | adb   | virtualbox | 10.10.10.42 |
      | cdk   | libvirt    | 10.10.10.42 |
      | adb   | libvirt    | 10.10.10.42 |
