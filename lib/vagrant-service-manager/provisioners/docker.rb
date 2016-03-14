module Vagrant
  module ServiceManager
    module Provisioner
      # Docker Service provisioner. Not related to in-built 'docker' provisioner
      class Docker
        def self.provision(machine)
          command = "sudo rm /etc/docker/ca.pem && sudo systemctl restart docker"
          machine.communicate.execute(command) do |type, data|
            if type == :stderr
              machine.error(data)
              exit 126
            end
          end
        end
      end
    end
  end
end
