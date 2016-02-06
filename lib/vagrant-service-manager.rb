module VagrantPlugins
  module DockerInfo
    class Plugin < Vagrant.plugin(2)
      name 'service-manager'

      command('service-manager', primary: false) do
        require_relative 'command'
        Command
      end
    end
  end
end
