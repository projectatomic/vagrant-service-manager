module VagrantPlugins
  module ServiceManager
    # Currently client binary installation of kubernetes for CDK is same as ADB
    class CDKKubernetesBinaryHandler < ADBKubernetesBinaryHandler
      def initialize(machine, env, options)
        super(machine, env, options)
      end
    end
  end
end
