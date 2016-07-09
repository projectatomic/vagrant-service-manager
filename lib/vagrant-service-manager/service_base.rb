module VagrantPlugins
  module ServiceManager
    class ServiceBase
      def initialize(machine, _env)
        @machine = machine
        @env = machine.env
        @ui = @env.ui
      end
    end
  end
end
