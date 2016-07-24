module VagrantPlugins
  module ServiceManager
    class CDKBinaryHandler < BinaryHandler
      def initialize(machine, env, options = {})
        super(machine, env, options)
      end
    end
  end
end
