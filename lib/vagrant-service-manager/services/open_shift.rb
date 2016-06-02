module VagrantPlugins
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
        PluginUtil.execute_and_exit_on_fail(@machine, @ui, command)
      end

      def self.status(machine, ui, service)
        PluginUtil.print_service_status(ui, machine, service)
      end

      def self.docker_registry_host(machine)
        url = ''
        PluginLogger.debug
        command = \
          "sudo oc --config=/var/lib/openshift/openshift.local." +
          "config/master/admin.kubeconfig get route/docker-registry " +
          "-o template --template={{.spec.host}}"
        machine.communicate.execute(command) do |type, data|
          url << data.chomp if type == :stdout
        end
        url
      end

      def self.info(machine, ui, options = {})
        options[:script_readable] ||= false

        if PluginUtil.service_running?(machine, 'openshift')
          options[:url] = "https://#{PluginUtil.machine_ip(machine)}:#{OPENSHIFT_PORT}"
          options[:console_url] = "#{options[:url]}/console"
          options[:docker_registry] = docker_registry_host(machine)
          print_info(ui, options)
        else
          ui.error I18n.t('servicemanager.commands.env.service_not_running',
                          name: 'OpenShift')
          exit 126
        end
      end

      def self.print_info(ui, options)
        PluginLogger.debug("script_readable: #{options[:script_readable] || false}")

        label = PluginUtil.env_label(options[:script_readable])
        message = I18n.t("servicemanager.commands.env.openshift.#{label}",
                         openshift_url: options[:url],
                         openshift_console_url: options[:console_url],
                         docker_registry: options[:docker_registry])
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
