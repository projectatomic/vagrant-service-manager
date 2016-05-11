require 'vagrant'
require File.expand_path('../../../../', __FILE__) + '/lib/vagrant-service-manager/plugin_logger'

module VagrantPlugins
  OS_RELEASE_FILE = '/etc/os-release'

  module GuestRedHat
    class Plugin < Vagrant.plugin('2')
      guest_capability('redhat', 'os_variant') do
        require_relative 'cap/os_variant'
        Cap::OsVariant
      end

      guest_capability('redhat', 'box_version') do
        require_relative 'cap/box_version'
        Cap::BoxVersion
      end

      guest_capability('redhat', 'sha_id') do
        require_relative 'cap/sha_id'
        Cap::ShaID
      end

      guest_capability('redhat', 'machine_ip') do
        require_relative 'cap/machine_ip'
        Cap::MachineIP
      end
    end
  end
end
