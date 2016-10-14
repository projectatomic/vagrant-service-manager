module VagrantPlugins
  module GuestRedHat
    module Cap
      class BoxVersion
        # Prints the version of the vagrant box, parses /etc/os-release for version
        def self.box_version(machine, options = {})
          command = "cat #{OS_RELEASE_FILE} | grep VARIANT"

          # TODO: execute efficient command to solve this
          return unless machine.communicate.test(command) # Return nil if command fails
          PluginLogger.debug
          machine.communicate.execute(command) do |type, data|
            if type == :stderr
              @env.ui.error(data)
              exit 126
            end

            return data.chomp if options[:script_readable]
            info = Hash[data.delete('"').split("\n").map { |e| e.split('=') }]
            return "#{info['VARIANT']} #{info['VARIANT_VERSION']}"
          end
        end
      end
    end
  end
end
