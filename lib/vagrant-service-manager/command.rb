require_relative 'os'

require 'net/scp'
require 'net/ssh'

module Vagrant
  module ServiceManager
    class Command < Vagrant.plugin(2, :command)
      OS_RELEASE_FILE = "/etc/os-release"
      def self.synopsis
        'provides the IP address:port and tls certificate file location for a docker daemon'
      end

      def exit_if_machine_not_running
        # Exit from plugin with status 3 if machine is not running
        with_target_vms(nil, {:single_target=>true}) do |machine|
          if machine.state.id != :running then
            message = <<-eos
  The virtual machine must be running before you execute this command.
  Try this in the directory with your Vagrantfile:
  vagrant up
              eos
            @env.ui.error(message)
            exit 3
          end
        end
      end

      def execute
        command, subcommand, option = ARGV[1..ARGV.length]
        case command
        when "env"
          self.exit_if_machine_not_running
          case subcommand
          when "docker"
            case option
            when nil
              self.execute_docker_info
            else
              self.print_help
            end
          when "openshift"
            case option
            when nil
              self.execute_openshift_info
            else
              self.print_help
            end
          when nil
            # display information about all the providers inside ADB/CDK
            self.print_all_provider_info
          else
            self.print_help(1)
          end
        when "box"
          self.exit_if_machine_not_running
          case subcommand
          when "version"
            case option
            when nil
              self.print_vagrant_box_version
            when "--script-readable"
              self.print_vagrant_box_version(true)
            else
                self.print_help(1)
            end
          else
            self.print_help
          end
        when "help"
            self.print_help
        else
            self.print_help(1)
        end
      end

      def print_help(exit_status=0)
        help_text = <<-help
Service manager for services inside vagrant box.

vagrant service-manager <verb> <object> [options]

Verb:
  env
    Display connection information for providers in the box.
    Example:
    Display information for all active providers in the box:
      $vagrant service-manager env
    Display information for docker provider in the box:
      $vagrant service-manager env docker
    Display information for openshift provider in the box:
      $vagrant service-manager env openshift
  box
    object
      version : Display version and release of the running vagrant box (from /etc/os-release)
        option
          --script-readable : Display the version and release in script readable (key=value) form
        help
        @env.ui.info(help_text)
        exit exit_status
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

      def check_if_a_service_is_running?(service)
        command = "systemctl status #{service}"
        with_target_vms(nil, {:single_target=>true}) do |machine|
          return machine.communicate.test(command)
        end
      end

      def print_all_provider_info
        message = <<-msg
# Showing the status of providers in the vagrant box:
        msg
        @env.ui.info(message)
        self.execute_docker_info
        self.execute_openshift_info
      end

      def execute_openshift_info
        @@OPENSHIFT_PORT = 8443
        if self.check_if_a_service_is_running?("openshift") then
          # Find the guest IP
          guest_ip = self.find_machine_ip
          openshift_url = "https://#{guest_ip}:#@@OPENSHIFT_PORT"
          openshift_console_url = "#{openshift_url}/console"
          self.print_openshift_info(openshift_url, openshift_console_url)
        else
          @env.ui.error("# OpenShift service is not running in the vagrant box.")
          exit 126
        end
      end

      def print_openshift_info(openshift_url, openshift_console_url)
        message =
        <<-eos
# You can access the OpenShift console on: #{openshift_console_url}
# To use OpenShift CLI, run: oc login #{openshift_url}
           eos
        @env.ui.info(message)
      end

      def find_machine_ip
        with_target_vms(nil, {:single_target=>true}) do |machine|
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
          return guest_ip
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
          guest_ip = self.find_machine_ip

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
          self.print_docker_env_info(guest_ip, port, secrets_path, machine.index_uuid)
        end
      end

      def print_docker_env_info(guest_ip, port, secrets_path, machine_uuid)
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

      def print_vagrant_box_version(script_readable = false)
        # Prints the version of the vagrant box, parses /etc/os-release for version
        with_target_vms(nil, { single_target: true}) do |machine|
          command = "cat #{OS_RELEASE_FILE} | grep VARIANT"

          machine.communicate.execute(command) do |type, data|
            if type == :stderr
              @env.ui.error(data)
              exit 126
            end

            if !script_readable
              info = Hash[data.gsub('"', '').split("\n").map {|e| e.split("=") }]
              version = "#{info['VARIANT']} #{info['VARIANT_VERSION']}"
              @env.ui.info(version)
            else
              @env.ui.info(data.chomp)
            end
          end
        end
      end
    end
  end
end
