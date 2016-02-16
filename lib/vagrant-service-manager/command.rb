require_relative 'os'

require 'net/scp'
require 'net/ssh'

module Vagrant
  module ServiceManager
    class Command < Vagrant.plugin(2, :command)

      def self.synopsis
        'provides the IP address:port and tls certificate file location for a docker daemon'
      end

      def exit_if_machine_not_running
        # Exit from plugin with status 1 if machine is not running
        with_target_vms(nil, {:single_target=>true}) do |machine|
          if machine.state.id != :running then
            message = <<-eos
  The virtual machine must be running before you execute this command.
  Try this in the directory with your Vagrantfile:
  vagrant up
              eos
            @env.ui.info(message)
            exit 1
          end
        end
      end

      def execute
        plugin_name, command, subcommand = ARGV
        case command
        when "env"
            self.exit_if_machine_not_running
            case subcommand
            when "docker"
                self.execute_docker_info
            when nil
                self.execute_docker_info
            else
                self.print_help
            end
        when "help"
            self.print_help
        else
            self.print_help
        end
      end

      def print_help
        help_text = <<-help
Service manager for services inside vagrant box.

vagrant service-manager <verb> <option>

Verb:
  env
    Configures and prints the required environment variables for Docker daemon

Example:
$vagrant service-manager env docker
        help
        @env.ui.info(help_text)
      end

      def copy_from_box(hIP, hport, husername, hprivate_key_path, source, destination)
        # This method should be extended to take an option 'if recursive'

        # read the private key
        fp = File.open(hprivate_key_path)
        pk_data = [fp.read]
        fp.close

        # create the ssh session
        Net::SSH.start(hIP, husername, :port => hport, :key_data => pk_data, :keys_only => TRUE) do |ssh|
          ssh.scp.download(source, destination, :recursive => TRUE)
        end
      end

      def execute_docker_info
        # this execute the operations needed to print the docker env info
        with_target_vms(nil, {:single_target=>true}) do |machine|
          # Path to the private_key and where we will store the TLS Certificates
          secrets_path = File.expand_path("docker", machine.data_dir)

          hIP = machine.ssh_info[:host]
          hport = machine.ssh_info[:port]
          husername = machine.ssh_info[:username]

          # Find the guest IP
          if machine.provider_name == :virtualbox then
              # VirtualBox automatically provisions an eth0 interface that is a NAT interface
              # We need a routeable IP address, which will therefore be found on eth1
              command = "ip addr show eth1 | awk 'NR==3 {print $2}' | cut -f1 -d\/"
          else
              # For all other provisions, find the default route
              command = "ip route get 8.8.8.8 | awk 'NR==1 {print $NF}'"
          end
          guest_ip = ""
          machine.communicate.execute(command) do |type, data|
            guest_ip << data.chomp if type == :stdout
          end

          # Hard Code the Docker port because it is fixed on the VM
          # This also makes it easier for the plugin to be cross-provider
          port = 2376

          # First, get the TLS Certificates, if needed
          if !File.directory?(secrets_path) then

            # Regenerate the certs and restart docker daemon in case of the new ADB box and for VirtualBox provider
            if machine.provider_name == :virtualbox then
              # `test` checks if the file exists, and then regenerates the certs and restart the docker daemon, else do nothing.
              command2 = "test ! -f /opt/adb/cert-gen.sh || (sudo rm /etc/docker/ca.pem && sudo systemctl restart docker)"
              machine.communicate.execute(command2)
            end

            # Get the private key
            hprivate_key_path = machine.ssh_info[:private_key_path][0]

            # copy the required client side certs from inside the box to host machine
            @env.ui.info("# Copying TLS certificates to #{secrets_path}")
            self.copy_from_box(hIP, hport, husername, hprivate_key_path, "/home/vagrant/.docker/ca.pem", "#{secrets_path}")
            self.copy_from_box(hIP, hport, husername, hprivate_key_path, "/home/vagrant/.docker/cert.pem", "#{secrets_path}")
            self.copy_from_box(hIP, hport, husername, hprivate_key_path, "/home/vagrant/.docker/key.pem", "#{secrets_path}")
          end

          # display the information, irrespective of the copy operation
          self.print_info(guest_ip, port, secrets_path, machine.index_uuid)
        end
      end

      def print_info(guest_ip, port, secrets_path, machine_uuid)
        # Print configuration information for accesing the docker daemon

        if !OS.windows? then
          message =
          <<-eos
# Set the following environment variables to enable access to the
# docker daemon running inside of the vagrant virtual machine:
export DOCKER_HOST=tcp://#{guest_ip}:#{port}
export DOCKER_CERT_PATH=#{secrets_path}
export DOCKER_TLS_VERIFY=1
export DOCKER_MACHINE_NAME=#{machine_uuid[0..6]}
# run following command to configure your shell:
# eval "$(vagrant service-manager env docker)"

          eos
          @env.ui.info(message)
        else
          # replace / with \ for path in Windows
          secrets_path = secrets_path.split('/').join('\\') + '\\'
          message =
          <<-eos
# Set the following environment variables to enable access to the
# docker daemon running inside of the vagrant virtual machine:
setx DOCKER_HOST tcp://#{guest_ip}:#{port}
setx DOCKER_CERT_PATH #{secrets_path}
setx DOCKER_TLS_VERIFY 1
setx DOCKER_MACHINE_NAME #{machine_uuid[0..6]}
          eos
          # puts is used here to escape and render the back slashes in Windows path
          @env.ui.info(puts(message))
        end
      end
    end
  end
end
