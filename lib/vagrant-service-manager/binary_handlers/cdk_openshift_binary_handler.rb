module VagrantPlugins
  module ServiceManager
    # Currently client binary installation of openshift for CDK is same as ADB
    class CDKOpenshiftBinaryHandler < ADBOpenshiftBinaryHandler
      # Default to latest stable origin oc version for CDK as it is different than
      # OSE oc version running inside CDK development environment
      LATEST_OC_VERSION = '1.3.1'.freeze

      def initialize(machine, env, options)
        options['--cli-version'] = LATEST_OC_VERSION unless options['--cli-version']
        super(machine, env, options)
      end
    end
  end
end
