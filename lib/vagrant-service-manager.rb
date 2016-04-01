begin
  require 'vagrant'
rescue LoadError
  raise 'The Vagrant vagrant-service-manager plugin must be run within Vagrant.'
end

require 'vagrant-service-manager/plugin'
require 'vagrant-service-manager/command'
require 'vagrant-service-manager/os'

module Vagrant
  module ServiceManager
    # Returns the path to the source of this plugin
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end

    # Temporally load the extra capabilities files for Red Hat
    load(File.join(source_root, 'plugins/guests/redhat/plugin.rb'))
    # Default I18n to load the en locale
    I18n.load_path << File.expand_path("locales/en.yml", source_root)
  end
end
