require_relative 'os'
module VagrantPlugins
  module DockerInfo
    class Command < Vagrant.plugin(2, :command)
      # Vagrant box password as defined in the Kickstart for the box <https://github.com/projectatomic/adb-atomic-developer-bundle/blob/master/build_tools/kickstarts/centos-7-adb-vagrant.ks>
      # On Windows, pscp utility is used to copy the client side certs to the host, password is used in the pscp command because the ssh keys can not be used. Refer issue #14 for details
      @@vagrant_box_password = "vagrant"

      def self.synopsis
        'provides the IP address:port and tls certificate file location for a docker daemon'
      end

      def execute
        with_target_vms(nil, {:single_target=>true}) do |machine|
          # Path to the private_key and where we will store the TLS Certificates
          secrets_path = machine.data_dir

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
          if !File.directory?(File.expand_path(".docker", secrets_path)) then

	    # Regenerate the certs and restart docker daemon in case of the new ADB box and for VirtualBox provider
            if machine.provider_name == :virtualbox then
            # `test` checks if the file exists, and then regenerates the certs and restart the docker daemon, else do nothing.
              command2 = "test ! -f /opt/adb/cert-gen.sh || (sudo rm /etc/docker/ca.pem && sudo systemctl restart docker)"
              machine.communicate.execute(command2)
            end

	    if !OS.windows? then
              hprivate_key_path = machine.ssh_info[:private_key_path][0]
              # scp over the client side certs from guest to host machine
              `scp -r -P #{hport} -o LogLevel=FATAL -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{hprivate_key_path} #{husername}@#{hIP}:/home/vagrant/.docker #{secrets_path}`
            else
              `pscp -r -P #{hport} -pw #@@vagrant_box_password -p #{husername}@#{hIP}:/home/vagrant/.docker #{secrets_path}`
            end
          end
         
         # display the information, irrespective of the copy operation
         print_info(guest_ip, port, secrets_path, machine.index_uuid)
        end
      end
    end
  end
end


def print_info(guest_ip, port, secrets_path, machine_uuid)
  # Print configuration information for accesing the docker daemon
  
  # extending the .docker path to include         
  secrets_path = File.expand_path(".docker", secrets_path)

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
# eval "$(vagrant svcmgr)"

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
