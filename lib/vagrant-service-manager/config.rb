require 'set'

module Vagrant
  module ServiceManager
    SERVICES = ['docker', 'openshift']

    class Config < Vagrant.plugin('2', :config)
      attr_accessor :services

      DEFAULTS = {
        services: 'docker'
      }

      def initialize
        super
        @services = UNSET_VALUE
      end

      def finalize!
        DEFAULTS.each do |name, value|
          if instance_variable_get('@' + name.to_s) == UNSET_VALUE
            instance_variable_set '@' + name.to_s, value
          end
        end
      end

      def validate(machine)
        errors = _detected_errors
        errors.concat(validate_services)
        { "servicemanager" => errors }
      end

      private

      def validate_services
        errors = []

        unless is_supported_services?
          errors << "services should be subset of #{SERVICES.inspect}.}"
        end

        errors
      end

      def is_supported_services?
        @services.split(',').map(&:strip).to_set.subset?(SERVICES.to_set)
      end
    end
  end
end
