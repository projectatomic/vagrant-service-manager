require_relative 'service_base'
# Loads all services
Dir["#{File.dirname(__FILE__)}/services/*.rb"].each { |f| require_relative f }

module VagrantPlugins
  module ServiceManager
    SUPPORTED_BOXES = %w(adb cdk).freeze

    class Service
      def initialize(app, env)
        @app = app
        @machine = env[:machine]
        @ui = env[:ui]
        @services = @machine.config.servicemanager.services.split(',').map(&:strip)
        @docker_hook = Docker.new(@machine, @ui)
        @openshift_hook = OpenShift.new(@machine, @ui)
      end

      def call(env)
        @app.call(env)

        if SUPPORTED_BOXES.include? @machine.guest.capability(:os_variant)
          # docker service needs to be started by default for ADB and CDK box
          @docker_hook.execute

          if @machine.guest.capability(:os_variant) == 'cdk' && @services.empty?
            # openshift to be started by default for CDK
            @openshift_hook.execute
          elsif @services.include? 'openshift'
            # Start OpenShift service if it is configured in Vagrantfile
            @openshift_hook.execute
          end
        end
      rescue Vagrant::Errors::GuestCapabilityNotFound
        # Do nothing if supported box variant not found
      end
    end
  end
end
