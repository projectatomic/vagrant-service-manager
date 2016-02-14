require "vagrant"

module Vagrant
  module ServiceManager
    class Plugin < Vagrant.plugin("2")
      name "service-manager"
      description "Service manager for services inside vagrant box."

      command 'service-manager' do
        require_relative 'command'
        Command
      end

      provisioner "docker" do
        require_relative "docker_provisioner"
        Provisioner
      end
    end
  end
end
