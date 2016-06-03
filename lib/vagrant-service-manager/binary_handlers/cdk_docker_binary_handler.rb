module VagrantPlugins
  module ServiceManager
    class CDKDockerBinaryHandler < CDKBinaryHandler
      def initialize(machine, env, options)
        super(machine, env, options)
      end
    end
  end
end
