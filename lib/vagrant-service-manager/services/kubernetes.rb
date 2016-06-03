module VagrantPlugins
  module ServiceManager
    class Kubernetes < ServiceBase
      def initialize(machine, env)
        super(machine, env)
        @service_name = 'kubernetes'
      end

      def execute
        # TODO: Implement execute method
      end

      def status
        PluginUtil.print_service_status(@ui, @machine, @service_name)
      end

      def info(options = {})
        # TODO: Implement info method
      end
    end
  end
end
