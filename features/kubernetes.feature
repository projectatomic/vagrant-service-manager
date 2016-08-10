Feature: Command output from various Kubernetes related commands
  service-manager should return the correct output from commands affecting Kubernetes

  Scenario Outline: Boot and execute commands
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

      config.servicemanager.services = 'kubernetes'
    end
    """

    When I successfully run `bundle exec vagrant up --provider <provider>`
    When I successfully run `bundle exec vagrant service-manager status kubernetes`
    Then stdout from "bundle exec vagrant service-manager status kubernetes" should contain "kubernetes - running"

    When I run `bundle exec vagrant service-manager install-cli kubernetes`
    Then the exit status should be 0
    And the binary "kubectl" should be installed

    Examples:
      | box   | provider   | ip          |
      | adb   | virtualbox | 10.10.10.42 |
      | adb   | libvirt    | 10.10.10.42 |
      | cdk   | virtualbox | 10.10.10.42 |
      | cdk   | libvirt    | 10.10.10.42 |
