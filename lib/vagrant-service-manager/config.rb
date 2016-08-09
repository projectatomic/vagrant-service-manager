require 'set'

module VagrantPlugins
  module ServiceManager
    SERVICES = %w(docker openshift kubernetes).freeze
    CONFIG_KEYS = [
      :services, :openshift_docker_registry,
      :openshift_image_name, :openshift_image_tag
    ].freeze

    class Config < Vagrant.plugin('2', :config)
      attr_accessor(*CONFIG_KEYS)

      DEFAULTS = {
        services: ''
      }.freeze

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

      def validate(_machine)
        errors = _detected_errors
        errors.concat(validate_services)
        { 'servicemanager' => errors }
      end

      private

      def validate_services
        errors = []

        unless supported_services?
          errors << I18n.t('servicemanager.config.supported_devices',
                           services: SERVICES.inspect)
        end

        errors
      end

      def supported_services?
        @services.split(',').map(&:strip).to_set.subset?(SERVICES.to_set)
      end
    end
  end
end
