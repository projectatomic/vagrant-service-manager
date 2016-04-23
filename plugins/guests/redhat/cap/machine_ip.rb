module VagrantPlugins
  module GuestRedHat
    module Cap
      class MachineIP
        def self.machine_ip(machine)
          # Find the guest IP
          command = "ip -o -4 addr show up |egrep -v ': docker|: lo' |tail -1 | awk '{print $4}' |cut -f1 -d\/"
          ip = ''
          machine.communicate.execute(command) do |type, data|
            ip << data.chomp if type == :stdout
          end
          ip
        end
      end
    end
  end
end
