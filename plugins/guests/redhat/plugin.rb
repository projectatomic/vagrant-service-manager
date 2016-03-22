require 'vagrant'

module VagrantPlugins
  module GuestRedHat
    class Plugin < Vagrant.plugin('2')
      guest_capability('redhat', 'os_variant') do
        require_relative 'cap/osvariant'
        Cap::OsVariant
      end

      guest_capability('redhat', 'sha_id') do
        require_relative 'cap/sha_id'
        Cap::ShaID
      end
    end
  end
end
