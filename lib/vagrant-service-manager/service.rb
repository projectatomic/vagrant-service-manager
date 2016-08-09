require_relative 'service_base'
# Loads all services
Dir["#{File.dirname(__FILE__)}/services/*.rb"].each { |f| require_relative f }

module VagrantPlugins
  module ServiceManager
    SUPPORTED_BOXES = %w(adb cdk).freeze

    class Service
      def initialize(app, env)
        @app = app
        @env = env
        @machine = env[:machine]
        @service_hooks = load_service_hooks
      end

      def call(env)
        @app.call(env)
        return false unless SUPPORTED_BOXES.include? @machine.guest.capability(:os_variant)
        @service_hooks.each(&:execute)
      end

      private

      def load_service_hooks
        SUPPORTED_SERVICES.map { |s| PluginUtil.service_class(s).new(@machine, @env) }
      end
    end
  end
end
