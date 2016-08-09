module VagrantPlugins
  module ServiceManager
    class OpenShift < ServiceBase
      PORT = 8443

      def initialize(machine, env)
        super(machine, env)
        @service_name = 'openshift'
        @extra_cmd = build_extra_command
      end

      def execute
        if service_start_allowed?
          # openshift to be started by default for CDK
          command = "#{@extra_cmd} sccli openshift"
          PluginUtil.execute_and_exit_on_fail(@machine, @ui, command)
        end
      rescue Vagrant::Errors::GuestCapabilityNotFound
        PluginLogger.debug('Guest capability not found while starting OpenShift service')
      end

      def status
        PluginUtil.print_service_status(@ui, @machine, @service_name)
      end

      def info(options = {})
        options[:script_readable] ||= false

        if PluginUtil.service_running?(@machine, 'openshift')
          options[:url] = "https://#{PluginUtil.machine_ip(@machine)}:#{PORT}"
          options[:console_url] = "#{options[:url]}/console"
          options[:docker_registry] = docker_registry_host
          print_info(options)
        else
          @ui.error I18n.t('servicemanager.commands.env.service_not_running',
                           name: 'OpenShift')
          exit 126
        end
      end

      def service_start_allowed?
        (cdk? && @services.empty?) || @services.include?('openshift')
      end

      private

      def build_extra_command
        cmd = ''
        CONFIG_KEYS.select { |e| e[/^openshift_/] }.each do |key|
          unless @machine.config.servicemanager.send(key).nil?
            env_name = key.to_s.gsub(/openshift_/, '').upcase
            cmd += "#{env_name}='#{@machine.config.servicemanager.send(key)}' "
          end
        end
        cmd.chop
      end

      def print_info(options)
        PluginLogger.debug("script_readable: #{options[:script_readable] || false}")

        label = PluginUtil.env_label(options[:script_readable])
        message = I18n.t("servicemanager.commands.env.openshift.#{label}",
                         openshift_url: options[:url],
                         openshift_console_url: options[:console_url],
                         docker_registry: options[:docker_registry])
        @ui.info(message)

        return if options[:script_readable] || options[:all]
        PluginUtil.print_shell_configure_info(@ui, ' openshift')
      end

      def docker_registry_host
        url = ''
        PluginLogger.debug
        command = \
          'sudo oc --config=/var/lib/openshift/openshift.local.' \
          'config/master/admin.kubeconfig get route/docker-registry ' \
          '-o template --template={{.spec.host}}'

        @machine.communicate.execute(command) do |type, data|
          url << data.chomp if type == :stdout
        end
        url
      end
    end
  end
end
