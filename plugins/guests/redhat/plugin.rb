require 'vagrant'

module VagrantPlugins
  module GuestRedHat
    class Plugin < Vagrant.plugin('2')
      guest_capability('redhat', 'flavor') do
        require_relative 'cap/flavor'
        Cap::Flavor
      end
    end
  end
end
