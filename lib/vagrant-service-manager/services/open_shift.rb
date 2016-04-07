module Vagrant
  module ServiceManager
    class OpenShift
      OPENSHIFT_PORT = 8443

      def initialize(machine, ui)
        @machine = machine
        @ui = ui
        @extra_cmd = build_extra_command
      end

      def execute
        command = "#{@extra_cmd} sccli openshift"
        Plugin.execute_and_exit_on_fail(@machine, @ui, command)
      end

      def self.status(machine, ui, service)
        PluginUtil.print_service_status(ui, machine, service)
      end

      def self.info(machine, ui, options = {})
        options[:script_readable] ||= false

        if PluginUtil.service_running?(machine, 'openshift')
          url = "https://#{PluginUtil.machine_ip(machine)}:#{OPENSHIFT_PORT}"
          print_info(ui, url, "#{url}/console", options[:script_readable])
        else
          ui.error I18n.t('servicemanager.commands.env.service_not_running',
                          name: 'OpenShift')
          exit 126
        end
      end

      def self.print_info(ui, url, console_url, script_readable)
        message = if script_readable
                    I18n.t('servicemanager.commands.env.openshift.script_readable',
                           openshift_url: url, openshift_console_url: console_url)
                  else
                    I18n.t('servicemanager.commands.env.openshift.default',
                           openshift_url: url, openshift_console_url: console_url)
                  end

        ui.info(message)
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
