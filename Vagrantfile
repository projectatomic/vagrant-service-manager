# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "projectatomic/adb"
  config.vm.network "private_network", type: "dhcp"
  # provision docker when machine boots up
  config.vm.provision :docker
end
