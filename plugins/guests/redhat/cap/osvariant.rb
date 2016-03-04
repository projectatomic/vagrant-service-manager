module VagrantPlugins
  module GuestRedHat
    module Cap
      class OsVariant
        def self.os_variant(machine)
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
