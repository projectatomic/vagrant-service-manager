module Vagrant
  module ServiceManager
    class OpenShift
      def initialize(machine, ui)
        @machine = machine
        @ui = ui
        @extra_cmd = build_extra_command
      end

      def execute
        errors = []
        full_cmd = "#{@extra_cmd} sccli openshift"

        exit_code = @machine.communicate.sudo(full_cmd) do |type, error|
          errors << error if type == :stderr
        end
        unless exit_code.zero?
          @env.ui.error errors.join("\n")
          exit exit_code
        end
        exit_code
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
