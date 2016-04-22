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
          options[:url] = "https://#{PluginUtil.machine_ip(machine)}:#{OPENSHIFT_PORT}"
          options[:console_url] = "#{options[:url]}/console"
          print_info(ui, options)
        else
          ui.error I18n.t('servicemanager.commands.env.service_not_running',
                          name: 'OpenShift')
          exit 126
        end
      end

      def self.print_info(ui, options)
        label = 'default'
        label = 'script_readable' if options[:script_readable]
        message = I18n.t("servicemanager.commands.env.openshift.#{label}",
                         openshift_url: options[:url],
                         openshift_console_url: options[:console_url])
        ui.info(message)
        unless options[:script_readable] || options[:all]
          PluginUtil.print_shell_configure_info(ui, ' openshift')
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
