# -*- mode: ruby -*-
# vi: set ft=ruby :

unless Vagrant.has_plugin?("vagrant-service-manager")
  $stderr.puts <<-MSG
    vagrant-service-manager plugin is required for projectatomic/adb.
    Kindly install the plugin: `$ vagrant plugin install vagrant-service-manager`
  MSG
  exit 126
end

Vagrant.configure(2) do |config|

  config.vm.box = "projectatomic/adb"

  config.vm.network "private_network", type: "dhcp"

  # This is the default setup
  # config.servicemanager.services = 'docker'

  # Enable multiple services as comma separated list.
  # config.servicemanager.services = 'docker, openshift'
end
