module VagrantPlugins
  module ServiceManager
    module Action
      class SetupNetwork
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          add_private_network if virtualbox? && default_network_exists?
          @app.call(env)
        end

        private

        def virtualbox?
          @machine.provider.instance_of?(VagrantPlugins::ProviderVirtualBox::Provider)
        end

        def default_network_exists?
          @machine.config.vm.networks.length == 1
        end

        def add_private_network
          @ui.info I18n.t('servicemanager.actions.private_network')
          @machine.config.vm.network :private_network, type: :dhcp
        end
      end
    end
  end
end
