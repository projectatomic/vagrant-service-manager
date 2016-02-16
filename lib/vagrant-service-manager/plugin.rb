require_relative "action/restart_service"

module Vagrant
  module ServiceManager
    class Plugin < Vagrant.plugin('2')
      name "service-manager"
      description "Service manager for services inside vagrant box."

      command 'service-manager' do
        require_relative 'command'
        Command
      end

      config 'servicemanager' do
        require_relative 'config'
        Config
      end

      action_hook(:servicemanager, :machine_action_up) do |hook|
        hook.append(Action::RestartService)
      end
    end
  end
end
