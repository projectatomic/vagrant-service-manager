module Vagrant
  module ServiceManager
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :providers

      def initialize
        super
        @providers = UNSET_VALUE
      end

      def finalize!
        # enable docker as provider by default
        @providers = 'docker' if @providers == UNSET_VALUE
      end

      def validate(machine)
        errors = _detected_errors
        { "servicemanager" => errors }
      end
    end
  end
end
