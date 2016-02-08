module Vagrant
  module DockerInfo
    class Plugin < Vagrant.plugin('2')
      name "service-manager"
      description "Service manager for services inside vagrant box."

      command 'service-manager' do
        require_relative 'command'
        Command
      end
    end
  end
end
