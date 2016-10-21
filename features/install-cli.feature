Feature: Command behavior of client side tools installation
  service-manager should correctly verify behavior of install-cli command

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

    Examples:
      | box   | provider   | ip          |
      | adb   | virtualbox | 10.10.10.42 |
      | adb   | libvirt    | 10.10.10.42 |
