module Vagrant
  module ServiceManager
    class OpenShift
      def initialize(machine, ui)
        @machine = machine
        @ui = ui
        @extra_cmd = build_extra_command
      end

      def execute
        full_cmd = "#{@extra_cmd} sccli openshift"

        @machine.communicate.sudo(full_cmd) do |type, data|
          if type == :stderr
            @ui.error(data)
            exit 126
          end
        end
      end

      private

      def build_extra_command
        cmd = ''
        CONFIG_KEYS.select {|e| e[/^openshift_/] }.each do |key|
          unless @machine.config.servicemanager.send(key).nil?
            env_name = key.to_s.gsub(/openshift_/,'').upcase
            cmd += "#{env_name}='#{@machine.config.servicemanager.send(key)}' "
          end
        end
        cmd.chop
      end
    end
  end
end
