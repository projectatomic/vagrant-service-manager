module VagrantPlugins
  module ServiceManager
    class Kubernetes
      def initialize(machine, ui)
        @machine = machine
        @ui = ui
      end

      def execute
        # TODO: Implement execute method
      end

      def self.status(machine, ui, service)
        PluginUtil.print_service_status(ui, machine, service)
      end

      def self.info(machine, ui, options = {})
        # TODO: Implement info method
      end
    end
  end
end
