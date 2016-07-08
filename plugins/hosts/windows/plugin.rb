require 'vagrant'

module VagrantPlugins
  module HostWindows
    class Plugin < Vagrant.plugin('2')
      host_capability('windows', 'os_arch') do
        require_relative 'cap/os_arch'

        Cap::OSArch
      end
    end
  end
end
