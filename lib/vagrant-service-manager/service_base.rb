module VagrantPlugins
  module ServiceManager
    class ServiceBase
      def initialize(machine, env)
        @machine = machine
        @env = machine.env
        @ui = @env.ui
      end
    end
  end
end
