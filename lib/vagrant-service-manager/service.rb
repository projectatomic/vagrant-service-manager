# Loads all actions
Dir["#{File.dirname(__FILE__)}/services/*.rb"].each { |f| require_relative f }

module Vagrant
  module ServiceManager
    SUPPORTED_BOXES = ['adb', 'cdk']

    class Service
      def initialize(app, env)
        @app = app
        @machine = env[:machine]
        @ui = env[:ui]
        @services = @machine.config.servicemanager.services.split(',').map(&:chomp)
        @docker_hook = Docker.new(@machine, @ui)
        @openshift_hook = OpenShift.new(@machine, @ui)
      end

      def call(env)
        if SUPPORTED_BOXES.include? @machine.guest.capability(:os_variant)
          @app.call(env)
          @docker_hook.execute

          if @machine.guest.capability(:os_variant) == "cdk"
            # openshift to be started by default for CDK
            @openshift_hook.execute
          elsif @services.include? "openshift"
            # Its ADB and start openshift service if it is configured in Vagrantfile
            @openshift_hook.execute
          end
        end
      end
    end
  end
end
