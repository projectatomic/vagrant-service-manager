module VagrantPlugins
  module GuestRedHat
    module Cap
      class Flavor
        def self.flavor(machine)
          machine.communicate.sudo("grep VARIANT_ID /etc/os-release") do |type, data|
            if type == :stderr
              @env.ui.error(data)
              exit 126
            end
            return data.chomp.gsub(/"/, '').split("=").last
          end
        end
      end
    end
  end
end
