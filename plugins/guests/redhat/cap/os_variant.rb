module VagrantPlugins
  module GuestRedHat
    module Cap
      class OsVariant
        def self.os_variant(machine)
          command = "grep VARIANT_ID #{OS_RELEASE_FILE}"
          # TODO: execute efficient command to solve this
          return unless machine.communicate.test(command) # Return nil if command fails
          machine.communicate.execute(command) do |_, data|
            return data.chomp.delete('"').split('=').last
          end
        end
      end
    end
  end
end
