module VagrantPlugins
  module ServiceManager
    class CDKOpenshiftBinaryHandler < CDKBinaryHandler
      def initialize(machine, env, options)
        super(machine, env, options)
      end
    end
  end
end
