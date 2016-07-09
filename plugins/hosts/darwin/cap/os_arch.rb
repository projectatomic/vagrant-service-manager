module VagrantPlugins
  module HostDarwin
    module Cap
      class OSArch
        def self.os_arch(_env)
          `uname -m`.chop
        end
      end
    end
  end
end
