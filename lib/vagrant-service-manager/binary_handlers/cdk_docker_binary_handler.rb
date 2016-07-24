module VagrantPlugins
  module ServiceManager
    # Currently client binary installation of docker for CDK is same as ADB
    class CDKDockerBinaryHandler < ADBDockerBinaryHandler
      def initialize(machine, env, options)
        super(machine, env, options)
      end
    end
  end
end
