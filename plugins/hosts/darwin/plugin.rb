require 'vagrant'

module VagrantPlugins
  module HostDarwin
    class Plugin < Vagrant.plugin('2')
      host_capability('darwin', 'os_arch') do
        require_relative 'cap/os_arch'

        Cap::OSArch
      end
    end
  end
end
