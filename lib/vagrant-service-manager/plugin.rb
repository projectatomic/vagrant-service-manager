# Loads all services and actions
Dir["#{File.dirname(__FILE__)}/services/*.rb"].each { |f| require_relative f }
Dir["#{File.dirname(__FILE__)}/action/*.rb"].each { |f| require_relative f }

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
        hook.before(VagrantPlugins::ProviderVirtualBox::Action::Network, setup_network)
        hook.after(Vagrant::Action::Builtin::SyncedFolders, Service::Docker)
      end

      def self.setup_network
        Vagrant::Action::Builder.new.tap do |b|
          b.use Action::SetupNetwork
        end
      end
    end
  end
end
