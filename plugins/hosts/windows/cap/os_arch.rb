module VagrantPlugins
  module HostWindows
    module Cap
      class OSArch
        def self.os_arch(env)
          # Logic taken from http://stackoverflow.com/a/25845488
          arch = 'x86_64'

          if ENV['PROCESSOR_ARCHITECTURE'] == 'x86'
            arch = 'i386' unless ENV['PROCESSOR_ARCHITEW6432']
          end

          arch
        end
      end
    end
  end
end
