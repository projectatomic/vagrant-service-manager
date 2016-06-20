Feature: Command output from env command
  service-manager should return the correct output from env commands

  @env
  Scenario Outline: Boot and execute env commands
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
    And I successfully run `bundle exec vagrant service-manager env --help`
    Then the exit status should be 0
    And stdout from "bundle exec vagrant service-manager env --help" should contain:
    """
    Usage: vagrant service-manager env [object] [options]

    Objects:
          docker      display information and environment variables for docker
          openshift   display information and environment variables for openshift

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
    And stdout from "bundle exec vagrant service-manager env docker" should contain "export DOCKER_API_VERSION=1.21"
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

    Examples:
      | box   | provider   | ip          |
      | cdk   | virtualbox | 10.10.10.42 |
      | adb   | virtualbox | 10.10.10.42 |
      | cdk   | libvirt    | 10.10.10.42 |
      | adb   | libvirt    | 10.10.10.42 |
