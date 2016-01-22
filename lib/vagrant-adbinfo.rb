module VagrantPlugins
  module DockerInfo
    class Plugin < Vagrant.plugin(2)
      name 'svcmgr'

      command('svcmgr', primary: false) do
        require_relative 'command'
        Command
      end
    end
  end
end
