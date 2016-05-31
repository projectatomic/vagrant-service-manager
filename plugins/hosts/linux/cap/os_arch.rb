include Vagrant::Util

module VagrantPlugins
  module HostLinux
    module Cap
      class OSArch
        def self.os_arch(env)
          if Platform.linux?
            `uname -m`.chop
          elsif Platform.windows?
            val = ENV['PROCESSOR_ARCHITECTURE']
            val == 'x86' ? 'x86_64' : 'i386'
          end
        rescue StandardError
          'NO ARCH'
        end
      end
    end
  end
end
