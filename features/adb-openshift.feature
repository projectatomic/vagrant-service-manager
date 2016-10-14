Feature: Command output from various OpenShift related commands in ADB
  service-manager should return the correct output from commands affecting OpenShift in ADB

  @ci-only
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

      config.servicemanager.services = 'docker, openshift'
    end
    """

    When I successfully run `bundle exec vagrant up --provider <provider>`
    Then stdout from "bundle exec vagrant up --provider <provider>" should contain:
    """
    ==> default: Docker service configured successfully...
    ==> default: OpenShift service configured successfully...
    """

    When I successfully run `bundle exec vagrant service-manager env openshift`
    Then stdout from "bundle exec vagrant service-manager env openshift" should be evaluable in a shell
    And stdout from "bundle exec vagrant service-manager env openshift" should contain:
    """
    # You can access the OpenShift console on: https://<ip>:8443/console
    # To use OpenShift CLI, run: oc login https://<ip>:8443
    export OPENSHIFT_URL=https://<ip>:8443
    export OPENSHIFT_WEB_CONSOLE=https://<ip>:8443/console
    export DOCKER_REGISTRY=hub.openshift.centos7-adb.<ip>.xip.io

    # run following command to configure your shell:
    # eval "$(vagrant service-manager env openshift)"
    """

    When I successfully run `bundle exec vagrant service-manager env openshift --script-readable`
    Then stdout from "bundle exec vagrant service-manager env openshift --script-readable" should be script readable
    And stdout from "bundle exec vagrant service-manager env openshift --script-readable" should contain:
    """
    OPENSHIFT_URL=https://<ip>:8443
    OPENSHIFT_WEB_CONSOLE=https://<ip>:8443/console
    DOCKER_REGISTRY=hub.openshift.centos7-adb.<ip>.xip.io
    """

    When I run `bundle exec vagrant service-manager install-cli openshift`
    Then the exit status should be 0
    And the binary "oc" should be installed

    # '../vagrant.d' maps to ENV['VAGRANT_HOME']
    When I run `bundle exec vagrant service-manager install-cli openshift --cli-version 1.3.0 --path ../vagrant.d/oc`
    Then the exit status should be 0
    And the binary "oc" should be installed with version "1.3.0"
    And the binary should be installed in path "ENV['VAGRANT_HOME']/oc"

    When I successfully run `bundle exec vagrant reload`
    And I successfully run `bundle exec vagrant service-manager status openshift`
    Then the exit status should be 0
    And the service "openshift" should be running

    Examples:
      | box   | provider   | ip          |
      | adb   | virtualbox | 10.10.10.42 |
