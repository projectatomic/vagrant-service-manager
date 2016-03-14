# require files other than 'base.rb'
Dir["#{File.dirname(__FILE__)}/*.rb"].each do |file|
  require_relative file if File.basename(file, '.*') != 'base'
end

module Vagrant
  module ServiceManager
    SUPPORTED_BOXES = ['adb', 'cdk']

    module Provisioner
      BASE_PATH = 'Vagrant::ServiceManager::Provisioner'
      # TODO: Load dynamically based on available provisioners
      PROVISIONERS = ['Docker']

      # Provisioner base class
      class Base < Vagrant.plugin(2, :provisioner)
        def provision
          if SUPPORTED_BOXES.include? @machine.guest.capability(:os_variant)
            PROVISIONERS.each do |provisioner|
              Object.const_get("#{BASE_PATH}::#{provisioner}").provision(@machine)
            end
          end
        end
      end
    end
  end
end
