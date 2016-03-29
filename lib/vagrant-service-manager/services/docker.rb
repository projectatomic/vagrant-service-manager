require_relative '../plugin_util'

module Vagrant
  module ServiceManager
    class Docker
      def initialize(machine, ui)
        @machine = machine
        @ui = ui
      end

      def execute
        command = "sudo rm /etc/docker/ca.pem && sudo systemctl restart docker"

        @machine.communicate.execute(command) do |type, data|
          if type == :stderr
            @ui.error(data)
            exit 126
          end
        end

        secrets_path = PluginUtil.host_docker_path(@machine)
        PluginUtil.copy_certs_to_host(@machine, secrets_path, @ui)
      end
    end
  end
end
