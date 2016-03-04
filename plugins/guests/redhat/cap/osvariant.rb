module VagrantPlugins
  module GuestRedHat
    module Cap
      class OsVariant
        def self.os_variant(machine)
          command = "grep VARIANT_ID /etc/os-release"
          # TODO: execute efficient command to solve this
          if machine.communicate.test(command) # test if command is exits with code 0
            machine.communicate.execute(command) do |type, data|
              return data.chomp.gsub(/"/, '').split("=").last
            end
          end
        end
      end
    end
  end
end
