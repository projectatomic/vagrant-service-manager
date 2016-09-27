module VagrantPlugins
  module ServiceManager
    class Installer
      def initialize(machine, env, options)
        @options = options
        @type = @options[:type]
        @machine = machine
        @env = env

        validate_prerequisites
        binary_handler_class = Object.const_get(handler_class)
        @binary_handler = binary_handler_class.new(machine, env, @options)
      end

      def handler_class
        "#{ServiceManager.name}::#{@options[:box_version].upcase}#{@type.capitalize}BinaryHandler"
      end

      def install
        @binary_handler.handle_windows_binary_path if Vagrant::Util::Platform.windows?
        unless PluginUtil.binary_downloaded?(@binary_handler.path)
          @binary_handler.binary_exists = false
          @binary_handler.install
        end

        @binary_handler.print_message
      end

      private

      def validate_prerequisites
        return if PluginUtil.service_running?(@machine, @type.to_s)
        @env.ui.info I18n.t('servicemanager.commands.install_cli.service_not_enabled',
                            service: @type)
        exit 126

        # return if --path is specified and directory mentioned by it exists
        return if @options.key?('--path') && File.exist?(File.dirname(@options['--path']))
        @env.ui.info I18n.t('servicemanager.commands.install_cli.invalid_binary_path',
                            dir_path: File.dirname(@options['--path']))
        exit 126
      end
    end
  end
end
