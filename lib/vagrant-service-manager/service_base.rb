module VagrantPlugins
  module ServiceManager
    class ServiceBase
      def initialize(machine, env)
        @machine = machine
        @env = env
        @ui = env.respond_to?('ui') ? env.ui : env[:ui]
        home_path = env.respond_to?('home_path') ? env.home_path : env[:home_path]
        @plugin_dir = File.join(home_path, 'data', 'service-manager')
        @services = @machine.config.servicemanager.services.split(',').map(&:strip)
      end

      def service_start_allowed?
        true # always start service by default
      end

      def cdk?
        @machine.guest.capability(:os_variant) == 'cdk'
      end
    end
  end
end
