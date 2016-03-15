# Loads all services
Dir["#{File.dirname(__FILE__)}/services/*.rb"].each { |f| require_relative f }

module Vagrant
  module ServiceManager
    SUPPORTED_BOXES = ['adb', 'cdk']

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
          @docker_hook.execute

          if @machine.guest.capability(:os_variant) == "cdk" and @services.length == 0
            # openshift to be started by default for CDK
            @openshift_hook.execute
          end
          if @services.include? "openshift"
            # Start OpenShift service if it is configured in Vagrantfile
            @openshift_hook.execute
          end
        end
      end
    end
  end
end
