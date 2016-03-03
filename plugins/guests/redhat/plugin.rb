require 'vagrant'

module VagrantPlugins
  module GuestRedHat
    class Plugin < Vagrant.plugin('2')
      guest_capability('redhat', 'os_variant') do
        require_relative 'cap/osvariant'
        Cap::OsVariant
      end
    end
  end
end
