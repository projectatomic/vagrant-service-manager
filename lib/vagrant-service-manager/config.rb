require 'set'

module VagrantPlugins
  module ServiceManager
    SERVICES = %w(docker openshift kubernetes).freeze
    BASE_CONFIG = [:services].freeze
    OPENSHIFT_CONFIG = [
      :openshift_docker_registry, :openshift_image_name, :openshift_image_tag
    ].freeze
    PROXY_CONFIG = [:proxy, :proxy_user, :proxy_password].freeze

    class Config < Vagrant.plugin('2', :config)
      attr_accessor(*(BASE_CONFIG + OPENSHIFT_CONFIG + PROXY_CONFIG))

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

        if SERVICES.drop(1).to_set.subset? configured_services.to_set
          errors << I18n.t('servicemanager.config.only_one_service')
        end

        errors
      end

      def supported_services?
        configured_services.to_set.subset? SERVICES.to_set
      end

      def configured_services
        @services.split(',').map(&:strip)
      end
    end
  end
end
