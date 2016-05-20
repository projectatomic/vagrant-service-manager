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
    And the "docker" service is running
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
