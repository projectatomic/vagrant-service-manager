require 'digest'
require_relative 'plugin_util'
require_relative 'plugin_logger'
require_relative 'installer'
require_relative 'archive_handlers/tar_handler'
require_relative 'archive_handlers/zip_handler'
require_relative 'binary_handlers/binary_handler'
require_relative 'binary_handlers/adb_binary_handler'
require_relative 'binary_handlers/cdk_binary_handler'
require_relative 'binary_handlers/adb_docker_binary_handler'
require_relative 'binary_handlers/adb_openshift_binary_handler'
require_relative 'binary_handlers/cdk_docker_binary_handler'
require_relative 'binary_handlers/cdk_openshift_binary_handler'

module VagrantPlugins
  module ServiceManager
    DOCKER_PATH = '/home/vagrant/.docker'.freeze
    SUPPORTED_SERVICES = %w(docker openshift kubernetes).freeze
    KUBE_SERVICES = [
      'etcd', 'kube-apiserver', 'kube-controller-manager', 'kube-scheduler',
      'kubelet', 'kube-proxy', 'docker'
    ].freeze
    # NOTE: SERVICES_MAP[<service>] will give fully-qualified service class name
    # Eg: SERVICES_MAP['docker'] gives Vagrant::ServiceManager::Docker
    SERVICES_MAP = {
      'docker' => Docker, 'openshift' => OpenShift,
      'kubernetes' => Kubernetes
    }.freeze

    def self.bin_dir
      @bin_dir
    end

    def self.temp_dir
      @temp_dir
    end

    def self.bin_dir=(path)
      @bin_dir = path
    end

    def self.temp_dir=(path)
      @temp_dir = path
    end

    class Command < Vagrant.plugin(2, :command)
      OS_RELEASE_FILE = '/etc/os-release'.freeze

      def self.synopsis
        I18n.t('servicemanager.synopsis')
      end

      def exit_if_machine_not_running
        # Exit from plugin with status 3 if machine is not running
        with_target_vms(nil, single_target: true) do |machine|
          PluginLogger.debug("machine state - #{machine.state.id || 'nil'}")
          if machine.state.id != :running
            @env.ui.error I18n.t('servicemanager.machine_should_running')
            exit 3
          end
        end
      end

      def execute
        ServiceManager.bin_dir = "#{@env.data_dir}/service-manager/bin"
        ServiceManager.temp_dir = "#{@env.data_dir}/service-manager/tmp"

        argv = ARGV.dup
        # Don't propagate --debug argument to case operation
        if ARGV.include? '--debug'
          PluginLogger.enable_debug_mode
          PluginLogger.set_logger(@logger)
          argv.delete('--debug')
        end

        # Remove first argument i.e plugin name
        command, subcommand, option = argv.drop(1)
        case command
        when 'env'
          exit_if_machine_not_running
          case subcommand
          when 'docker', 'openshift'
            case option
            when nil
              execute_service(subcommand)
            when '--script-readable'
              execute_service(subcommand, script_readable: true)
            when '--help', '-h'
              print_help(type: command)
            else
              print_help(type: command, exit_status: 1)
            end
          when nil
            # display information about all the providers inside ADB/CDK
            print_all_provider_info
          when '--script-readable'
            print_all_provider_info(script_readable: true)
          when '--help', '-h'
            print_help(type: command)
          else
            print_help(type: command, exit_status: 1)
          end
        when 'status'
          exit_if_machine_not_running
          case subcommand
          when nil
            execute_status_display
          when '--help', '-h'
            print_help(type: command)
          else
            execute_status_display(subcommand)
          end
        when 'box'
          exit_if_machine_not_running
          case subcommand
          when 'version'
            case option
            when nil
              print_vagrant_box_version
            when '--script-readable'
              print_vagrant_box_version(true)
            when '--help', '-h'
              print_help(type: command)
            else
              print_help(type: command, exit_status: 1)
            end
          when 'ip'
            case option
            when nil
              display_box_ip
            when '--script-readable'
              display_box_ip(true)
            when '--help', '-h'
              print_help(type: command)
            else
              print_help(type: command, exit_status: 1)
            end
          when '--help', '-h'
            print_help(type: command)
          else
            print_help(type: command, exit_status: 1)
          end
        when 'restart', 'start', 'stop'
          exit_if_machine_not_running
          case subcommand
          when '--help', '-h'
            print_help(type: 'operation', operation: command)
          else
            perform_service(command, subcommand)
          end
        when 'install-cli'
          exit_if_machine_not_running
          # Transform hyphen into underscore which is valid char in method
          command = command.tr('-', '_')
          # Get options as Hash which are preceeded with -- like --version
          options = Hash[ARGV.drop(3).each_slice(2).to_a]

          case subcommand
          when '--help', '-h'
            print_help(type: command)
          else
            execute_install_cli(subcommand, options)
          end
        when '--help', '-h', 'help'
          print_help
        else
          print_help(exit_status: 1)
        end
      end

      def execute_service(name, options = {})
        with_target_vms(nil, single_target: true) do |machine|
          PluginUtil.service_class(name).new(machine, @env).info(options)
        end
      end

      def print_help(config = {})
        config[:type] ||= 'default'
        config[:exit_status] ||= 0

        @env.ui.info(I18n.t("servicemanager.commands.help.#{config[:type]}", operation: config[:operation]))
        exit config[:exit_status]
      end

      def execute_status_display(service = nil)
        with_target_vms(nil, single_target: true) do |machine|
          if service && SUPPORTED_SERVICES.include?(service)
            PluginUtil.service_class(service).new(machine, @env).status
          elsif service.nil?
            @env.ui.info I18n.t('servicemanager.commands.status.nil')
            SUPPORTED_SERVICES.each do |s|
              PluginUtil.service_class(s).new(machine, @env).status
            end
          else
            @env.ui.error I18n.t('servicemanager.commands.status.unsupported_service',
                                 service: service, services: SUPPORTED_SERVICES.join(', ') + ' etc')
            exit 126
          end
        end
      end

      def print_all_provider_info(options = {})
        with_target_vms(nil, single_target: true) do |machine|
          options[:all] = true # flag to mark all providers
          running_service_classes = PluginUtil.running_services(machine, class: true)

          running_service_classes.each do |service_class|
            service = service_class.to_s.split('::').last.downcase
            unless options[:script_readable] || service == 'kubernetes'
              @env.ui.info("\n# #{service} env:")
            end
            # since we do not have feature to show the Kube connection information
            unless service == 'kubernetes'
              service_class.new(machine, @env).info(options)
            end
          end

          PluginUtil.print_shell_configure_info(@env.ui) unless options[:script_readable]
        end
      end

      def print_vagrant_box_version(script_readable = false)
        options = { script_readable: script_readable }

        with_target_vms(nil, single_target: true) do |machine|
          @env.ui.info machine.guest.capability(:box_version, options)
        end
      end

      def perform_service(operation, service)
        if service.nil?
          help_msg = I18n.t('servicemanager.commands.help.operation', operation: operation)
          service_missing_msg = I18n.t('servicemanager.commands.operation.service_missing')
          @env.ui.error help_msg.gsub(/#{operation}s the service/, service_missing_msg)
          exit 126
        end

        command = if SUPPORTED_SERVICES.include? service
                    # TODO : Handle the case where user wants to pass extra arguments
                    # to OpenShift service
                    "sccli #{service} #{operation}"
                  else
                    @env.ui.error I18n.t('servicemanager.commands.operation.sccli_only_support')
                    exit 126
                  end

        with_target_vms(nil, single_target: true) do |machine|
          PluginUtil.execute_and_exit_on_fail(machine, @env.ui, command)
        end
      end

      def display_box_ip(script_readable = false)
        options = { script_readable: script_readable }

        with_target_vms(nil, single_target: true) do |machine|
          @env.ui.info machine.guest.capability(:machine_ip, options)
        end
      end

      def execute_install_cli(service, options = {})
        help_msg = I18n.t('servicemanager.commands.help.install_cli')

        if service.nil?
          service_missing_msg = I18n.t('servicemanager.commands.operation.service_missing')
          @env.ui.error help_msg.gsub(/Install the client side tool for the service/, service_missing_msg)
          exit 126
        end

        unless SUPPORTED_SERVICES.include?(service)
          @env.ui.error "Unknown service '#{service}'."
          @env.ui.error help_msg.gsub(/Install the client side tool for the service\n/, '')
          exit 126
        end

        with_target_vms(nil, single_target: true) do |machine|
          args = [service.to_sym, machine, @env, options]

          begin
            args.last[:box_version] = machine.guest.capability(:os_variant)
            Installer.new(*args).install
          rescue Vagrant::Errors::GuestCapabilityNotFound
            ui.info 'Not a supported box.'
            exit 126
          end
        end
      end
    end
  end
end
