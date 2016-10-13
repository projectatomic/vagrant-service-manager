# Loads all actions
Dir["#{File.dirname(__FILE__)}/action/*.rb"].each { |f| require_relative f }
require_relative 'service'

module VagrantPlugins
  module ServiceManager
    class Plugin < Vagrant.plugin('2')
      name 'service-manager'
      description 'Service manager for services inside vagrant box.'

      command 'service-manager' do
        require_relative 'command'
        Command
      end

      config 'servicemanager' do
        require_relative 'config'
        Config
      end

      service_manager_hooks = lambda do |hook|
        hook.before VagrantPlugins::ProviderVirtualBox::Action::Network, setup_network
        hook.after Vagrant::Action::Builtin::SyncedFolders, Service
        hook.after Vagrant::Action::Builtin::Provision, final_actions
      end

      action_hook :servicemanager, :machine_action_up, &service_manager_hooks
      action_hook :servicemanager, :machine_action_reload, &service_manager_hooks

      def self.setup_network
        Vagrant::Action::Builder.new.tap do |b|
          b.use Action::SetupNetwork
        end
      end

      def self.final_actions
        Vagrant::Action::Builder.new.tap do |b|
          b.use Action::LogConfiguredServices
        end
      end
    end
  end
end
