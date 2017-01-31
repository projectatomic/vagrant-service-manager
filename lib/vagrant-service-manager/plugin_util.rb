module VagrantPlugins
  module ServiceManager
    module PluginUtil
      def self.service_class(service)
        SERVICES_MAP[service]
      end

      def self.copy_certs_to_host(machine, path, ui, commented_message = false)
        Dir.mkdir(path) unless Dir.exist?(path)

        # Copy the required client side certs from inside the box to host machine
        message = "Copying TLS certificates to #{path}"
        message = '# ' + message.to_s if commented_message
        ui.info(message)
        machine.communicate.download("#{DOCKER_PATH}/ca.pem", path.to_s)
        machine.communicate.download("#{DOCKER_PATH}/cert.pem", path.to_s)
        machine.communicate.download("#{DOCKER_PATH}/key.pem", path.to_s)
      end

      def self.generate_kubeconfig(machine, ui, plugin_dir)
        FileUtils.mkdir_p(plugin_dir) unless File.directory?(plugin_dir)
        File.open("#{plugin_dir}/kubeconfig", 'w') do |config_file|
          config_file.write(I18n.t('servicemanager.kube_config',
                                   ip: PluginUtil.machine_ip(machine),
                                   token: service_token(machine, ui)))
        end
      end

      def self.service_token(machine, ui)
        token_template = '-o template --template="{{(index .secrets 0).name}}"'
        secret_template = '-o template --template="{{.data.token}}"'
        secret_name_cmd = "$(kubectl get serviceaccounts default #{token_template})"

        cmd = "kubectl get secret #{secret_name_cmd} #{secret_template} | base64 -d"
        execute_once(machine, ui, cmd)
      end

      def self.host_docker_path(machine)
        # Path to the private_key and where we will store the TLS Certificates
        File.expand_path('docker', machine.data_dir)
      end

      def self.machine_ip(machine)
        machine.guest.capability(:machine_ip)
      end

      def self.sha_id(file_data)
        Digest::SHA256.hexdigest file_data
      end

      def self.certs_present_and_valid?(path, machine)
        return false if Dir["#{path}/*"].empty?

        # check validity of certs
        Dir[path + '/*'].each do |f|
          guest_file_path = "#{DOCKER_PATH}/#{File.basename(f)}"
          guest_sha = machine.guest.capability(:sha_id, guest_file_path)
          return false if sha_id(File.read(f)) != guest_sha
        end

        true
      end

      def self.print_service_status(ui, machine, service)
        status = I18n.t('servicemanager.commands.status.status.stopped')
        if service_running?(machine, service)
          status = I18n.t('servicemanager.commands.status.status.running')
        end
        ui.info("#{service} - #{status}")
      end

      # If 'class' option is true then return the class name of running services
      def self.running_services(machine, options = {})
        running_services = []

        SUPPORTED_SERVICES.each do |service|
          next unless service_running?(machine, service)
          running_services << (options[:class] ? SERVICES_MAP[service] : service)
        end
        running_services
      end

      def self.service_running?(machine, service)
        command = "sudo sccli #{service} status"
        machine.communicate.test(command)
      end

      def self.windows_path(path)
        # Replace / with \ for path in Windows
        path.split('/').join('\\') + '\\'
      end

      def self.execute_and_exit_on_fail(machine, ui, command)
        errors = []
        logged = false # Log one time only

        exit_code = machine.communicate.sudo(command) do |type, data|
          PluginLogger.debug unless logged
          errors << data if type == :stderr
          logged = true
        end

        unless exit_code.zero?
          ui.error errors.join("\n")
          PluginLogger.debug("#{command} exited with code #{exit_code}")
          exit exit_code
        end

        exit_code
      end

      def self.execute_once(machine, ui, command)
        machine.communicate.sudo(command) do |_, data|
          next if data.chomp.empty?
          PluginLogger.debug
          return data.chomp
        end
      rescue StandardError => e
        ui.error e.message.squeeze
      end

      def self.print_shell_configure_info(ui, command = '')
        label = if !Vagrant::Util::Platform.windows?
                  'unix_configure_info'
                elsif Vagrant::Util::Platform.cygwin?
                  'windows_cygwin_configure_info'
                end

        ui.info "\n" + I18n.t("servicemanager.commands.env.#{label}", command: command) unless label.nil?
      end

      def self.env_label(script_readable)
        if script_readable
          'script_readable'
        elsif !Vagrant::Util::Platform.windows?
          'non_windows'
        elsif Vagrant::Util::Platform.cygwin?
          'windows_cygwin'
        else
          'windows'
        end
      end

      def self.binary_downloaded?(path)
        File.file?(path)
      end

      def self.format_path(path)
        if Vagrant::Util::Platform.cygwin?
          Vagrant::Util::Platform.cygwin_path(path)
        elsif Vagrant::Util::Platform.windows?
          windows_path(path).chop
        else
          path
        end
      end

      # special case for oc binary in windows
      def self.fetch_existing_oc_binary_path_in_windows
        separator = ';'
        path_string = ENV['PATH']

        separator = ':' unless path_string.include?(';')
        oc_path_dir = path_string.split(separator).detect do |dir_path|
          File.exist? "#{dir_path}\\oc.exe"
        end

        oc_path_dir.nil? ? nil : oc_path_dir + '\oc.exe'
      end
    end
  end
end
