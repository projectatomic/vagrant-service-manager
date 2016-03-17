module Vagrant
  module ServiceManager
    module Action
      class SetupNetwork

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          add_private_network if virtualbox? && !private_network_exists?
          @app.call(env)
        end

        private

        def virtualbox?
          @machine.provider.instance_of?(VagrantPlugins::ProviderVirtualBox::Provider)
        end

        def private_network_exists?
          @machine.config.vm.networks.any? { |type, _| type == :private_network }
        end

        def add_private_network
          @ui.info <<-MSG
When using virtualbox, a non-NAT network interface is required.
Adding a private network using DHCP
          MSG
          @machine.config.vm.network :private_network, type: :dhcp
        end

      end
    end
  end
end
