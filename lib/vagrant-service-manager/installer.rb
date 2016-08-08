module VagrantPlugins
  module ServiceManager
    class Installer
      def initialize(type, machine, env, options)
        @type = type
        @machine = machine
        @env = env
        @box_version = options.delete(:box_version)

        validate_prerequisites
        binary_handler_class = Object.const_get(handler_class)
        @binary_handler = binary_handler_class.new(machine, env, { type: @type }.merge(options))
      end

      def handler_class
        "#{ServiceManager.name}::#{@box_version.upcase}#{@type.capitalize}BinaryHandler"
      end

      def install
        unless PluginUtil.binary_downloaded?(@binary_handler.path)
          @binary_handler.binary_exists = false
          @binary_handler.install
        end

        @binary_handler.print_message
      end

      private

      def validate_prerequisites
        unless PluginUtil.service_running?(@machine, @type.to_s)
          @env.ui.info I18n.t('servicemanager.commands.install_cli.service_not_enabled',
                              service: @type)
          exit 126
        end
      end
    end
  end
end
