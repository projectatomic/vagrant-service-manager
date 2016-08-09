module VagrantPlugins
  module ServiceManager
    class Kubernetes < ServiceBase
      def initialize(machine, env)
        super(machine, env)
        @service_name = 'kubernetes'
      end

      def execute
        if service_start_allowed?
          command = 'sccli kubernetes'
          PluginUtil.execute_and_exit_on_fail(@machine, @ui, command)
        end
      end

      def status
        PluginUtil.print_service_status(@ui, @machine, @service_name)
      end

      def info(options = {})
        # TODO: Implement info method
      end

      def service_start_allowed?
        @services.include?('kubernetes')
      end
    end
  end
end
