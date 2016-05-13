Feature: Command output from status command
  service-manager should return the correct output from status command

  @status
  Scenario Outline: Boot and execute status command
    Given box is <box>
    And provider is <provider>
    And a file named "Vagrantfile" with:
    """
    require 'vagrant-libvirt'

    Vagrant.configure('2') do |config|
      config.vm.box = '<box>'
      config.vm.box_url = 'file://../boxes/<box>-<provider>.box'
      config.vm.network :private_network, ip: '<ip>'
      config.vm.synced_folder '.', '/vagrant', disabled: true
      config.servicemanager.services = 'docker'
    end
    """

    When I successfully run `bundle exec vagrant up --provider <provider>`
    And I successfully run `bundle exec vagrant service-manager status`
    Then stdout from "bundle exec vagrant service-manager status" should contain "docker - running"
    Then stdout from "bundle exec vagrant service-manager status" should contain "openshift - stopped"

    Examples:
      | box   | provider   | ip          |
      | cdk   | virtualbox | 10.10.10.42 |
      | adb   | virtualbox | 10.10.10.42 |
      | cdk   | libvirt    | 10.10.10.42 |
      | adb   | libvirt    | 10.10.10.42 |