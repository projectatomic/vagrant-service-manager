module Vagrant
  module ServiceManager
    module PluginUtil
      def self.copy_certs_to_host(machine, path, ui, commented_message = false)
        Dir.mkdir(path) unless Dir.exist?(path)

        # Copy the required client side certs from inside the box to host machine
        message = "Copying TLS certificates to #{path}"
        message = '# ' + message.to_s if commented_message
        ui.info(message)
        machine.communicate.download("#{DOCKER_PATH}/ca.pem", path.to_s)
        machine.communicate.download("#{DOCKER_PATH}/cert.pem", path.to_s)
        machine.communicate.download("#{DOCKER_PATH}/key.pem", path.to_s)
      end

      def self.host_docker_path(machine)
        # Path to the private_key and where we will store the TLS Certificates
        File.expand_path("docker", machine.data_dir)
      end
    end
  end
end
