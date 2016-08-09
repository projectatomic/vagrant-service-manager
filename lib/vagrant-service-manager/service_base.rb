module VagrantPlugins
  module ServiceManager
    class ServiceBase
      def initialize(machine, env)
        @machine = machine
        @env = env
        @ui = env.respond_to?('ui') ? env.ui : env[:ui]
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
