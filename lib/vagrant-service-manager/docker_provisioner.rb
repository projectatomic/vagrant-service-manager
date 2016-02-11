module Vagrant
  module ServiceManager
    class Provisioner < Vagrant.plugin("2", :provisioner)

      def configure(root_config)
        super(root_config)
      end

      def provision
        command = "sudo rm /etc/docker/ca.pem && sudo systemctl restart docker"
        @machine.communicate.execute(command) do |type, data|
          if type == :stderr
            @machine.ui.error(data)
          else
            @env.ui.info("# Provisioned docker provider")
          end
        end
      end
    end
  end
end
