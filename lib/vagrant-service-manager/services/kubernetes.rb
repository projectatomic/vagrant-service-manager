module VagrantPlugins
  module ServiceManager
    class Kubernetes < ServiceBase
      def initialize(machine, env)
        super(machine, env)
        @service_name = 'kubernetes'
        @kubeconfig_path = "#{@plugin_dir}/kubeconfig"
      end

      def execute
        if service_start_allowed?
          command = 'sccli kubernetes'
          exit_code = PluginUtil.execute_and_exit_on_fail(@machine, @ui, command)
          PluginUtil.generate_kubeconfig(@machine, @ui, @plugin_dir) if exit_code.zero?
        end
      rescue StandardError => e
        @ui.error e.message.squeeze
        exit 126
      end

      def status
        PluginUtil.print_service_status(@ui, @machine, @service_name)
      end

      def info(options = {})
        if PluginUtil.service_running?(@machine, @service_name)
          options[:kubeconfig_path] = @kubeconfig_path
          print_env_info(options)
        else
          @ui.error I18n.t('servicemanager.commands.env.service_not_running',
                           name: @service_name)
          exit 126
        end
      end

      def service_start_allowed?
        @services.include?('kubernetes')
      end

      private

      def print_env_info(options)
        PluginLogger.debug("script_readable: #{options[:script_readable] || false}")

        label = PluginUtil.env_label(options[:script_readable])
        message = I18n.t("servicemanager.commands.env.kubernetes.#{label}",
                         kubeconfig_path: options[:kubeconfig_path])
        @ui.info(message)

        return if options[:script_readable] || options[:all]
        PluginUtil.print_shell_configure_info(@ui, ' kubernetes')
      end
    end
  end
end
