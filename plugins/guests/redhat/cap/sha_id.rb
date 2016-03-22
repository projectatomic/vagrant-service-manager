module VagrantPlugins
  module GuestRedHat
    module Cap
      class ShaID
        def self.sha_id(machine, path)
          command = "sha256sum #{path}"

          if machine.communicate.test(command)
            machine.communicate.execute(command) do |type, data|
              # sha256sum results in "sha_id path"
              return data.split.first
            end
          end
        end
      end
    end
  end
end
