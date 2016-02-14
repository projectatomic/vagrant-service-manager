begin
  require 'vagrant'
rescue LoadError
  raise 'The Vagrant vagrant-service-manager plugin must be run within Vagrant.'
end

require 'vagrant-service-manager/plugin'
require 'vagrant-service-manager/command'
require 'vagrant-service-manager/os'
require 'vagrant-service-manager/docker_provisioner'

module Vagrant
  module DockerInfo
    # Returns the path to the source of this plugin
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
