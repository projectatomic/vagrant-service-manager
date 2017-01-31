module VagrantPlugins
  module GuestRedHat
    module Cap
      class ShaID
        def self.sha_id(machine, path)
          command = "sha256sum #{path}"

          return unless machine.communicate.test(command) # Return nil if command fails
          machine.communicate.execute(command) do |_, data|
            next if data.chomp.empty?
            # sha256sum results in "sha_id path"
            return data.split.first
          end
        end
      end
    end
  end
end
