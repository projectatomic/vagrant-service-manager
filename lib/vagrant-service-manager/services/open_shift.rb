module Vagrant
  module ServiceManager
    class OpenShift
      def initialize(machine, ui)
        @machine = machine
        @ui = ui
      end

      def execute
        command = "sudo sccli openshift"
        @machine.communicate.execute(command) do |type, data|
          if type == :stderr
            @ui.error(data)
            exit 126
          end
        end
      end
    end
  end
end
