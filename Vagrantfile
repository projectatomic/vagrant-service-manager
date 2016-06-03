# -*- mode: ruby -*-
# vi: set ft=ruby :

if ENV['SERVICE_MANAGER_TEST'] != 'true' && !Vagrant.has_plugin?("vagrant-service-manager")
  $stderr.puts <<-MSG
    vagrant-service-manager plugin is required for projectatomic/adb.
    Kindly install the plugin: `$ vagrant plugin install vagrant-service-manager`
  MSG
  exit 126
end

Vagrant.configure(2) do |config|

  config.vm.box = "projectatomic/adb"

  #config.vm.network "private_network", ip: "192.168.33.10"
  #config.vm.network "private_network", type: "dhcp"

  # This is the default setup
  # config.servicemanager.services = 'docker'

  # Enable multiple services as comma separated list.
  # config.servicemanager.services = 'docker, openshift'

  # Specific versions can be specified using the following variables for OpenShift service:
  # config.servicemanager.openshift_docker_registry = "docker.io"
  # config.servicemanager.openshift_image_name = "openshift/origin"
  # config.servicemanager.openshift_image_tag = "v1.1.1"
end
