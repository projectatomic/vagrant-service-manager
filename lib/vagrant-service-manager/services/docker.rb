module VagrantPlugins
  module ServiceManager
    class Docker
      # Hard Code the Docker port because it is fixed on the VM
      # This also makes it easier for the plugin to be cross-provider
      PORT = 2376
      # Refer https://docs.docker.com/v1.10/engine/installation/binaries/
      CLIENT_BINARY_BASE_URL = 'https://get.docker.com/builds/'

      def initialize(machine, ui)
        @machine = machine
        @ui = ui
      end

      def execute
        command = 'sudo rm /etc/docker/ca.pem && sudo systemctl restart docker'

        exit_code = PluginUtil.execute_and_exit_on_fail(@machine, @ui, command)
        # Copy certs on command execution success
        if exit_code
          secrets_path = PluginUtil.host_docker_path(@machine)
          PluginUtil.copy_certs_to_host(@machine, secrets_path, @ui)
        end
      end

      def self.status(machine, ui, service)
        PluginUtil.print_service_status(ui, machine, service)
      end

      def self.info(machine, ui, options = {})
        if PluginUtil.service_running?(machine, 'docker')
          options[:secrets_path] = PluginUtil.host_docker_path(machine)
          options[:guest_ip] = PluginUtil.machine_ip(machine)

          # Verify valid certs and copy if invalid
          unless PluginUtil.certs_present_and_valid?(options[:secrets_path], machine)
            # Log the message prefixed by #
            PluginUtil.copy_certs_to_host(machine, options[:secrets_path], ui, true)
          end

          api_version_cmd = "docker version --format '{{.Server.APIVersion}}'"
          unless machine.communicate.test(api_version_cmd)
            # fix for issue #152: Fallback to older Docker version (< 1.9.1)
            api_version_cmd.gsub!(/APIVersion/, 'ApiVersion')
          end

          options[:api_version] = PluginUtil.execute_once(machine, ui, api_version_cmd)
          # Display the information, irrespective of the copy operation
          print_env_info(ui, options)
        else
          ui.error I18n.t('servicemanager.commands.env.service_not_running',
                          name: 'Docker')
          exit 126
        end
      end

      def self.print_env_info(ui, options)
        PluginLogger.debug("script_readable: #{options[:script_readable] || false}")

        label = PluginUtil.env_label(options[:script_readable])
        options[:secrets_path] = PluginUtil.windows_path(options[:secrets_path]) unless OS.unix?
        message = I18n.t("servicemanager.commands.env.docker.#{label}",
                         ip: options[:guest_ip], port: PORT, path: options[:secrets_path],
                         api_version: options[:api_version])
        # Puts is used to escape and render the back slashes in Windows path
        message = puts(message) if OS.windows?
        ui.info(message)
        unless options[:script_readable] || options[:all]
          PluginUtil.print_shell_configure_info(ui, ' docker')
        end
      end

      def self.install_cli(machine, ui)
        label = 'servicemanager.commands.install_cli.message'
        action = 'downloaded'
        version_cmd = "docker version --format '{{.Server.Version}}'"
        version = PluginUtil.execute_once(machine, ui, version_cmd)

        if PluginUtil.binary_downloaded?(version)
          path = "#{BIN_FOLDER}docker-#{version}"
          action = 'already available'
        else
          url = PluginUtil.download_url(machine, CLIENT_BINARY_BASE_URL, version)
          path = PluginUtil.download_binary(ui, url)
        end

        message = I18n.t(label, path: path, action: action)
        ui.info message
      end
    end
  end
end
