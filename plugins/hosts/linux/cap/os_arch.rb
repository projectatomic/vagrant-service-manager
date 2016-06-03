module VagrantPlugins
  module HostLinux
    module Cap
      class OSArch
        def self.os_arch(env)
          `uname -m`.chop
        end
      end
    end
  end
end
