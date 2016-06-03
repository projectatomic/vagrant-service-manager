require 'vagrant'

module VagrantPlugins
  module HostLinux
    class Plugin < Vagrant.plugin('2')
      host_capability('linux', 'os_arch') do
        require_relative 'cap/os_arch'

        Cap::OSArch
      end
    end
  end
end
