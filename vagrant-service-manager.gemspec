$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
require 'vagrant-service-manager/version'

Gem::Specification.new do |spec|
  spec.name          = 'vagrant-service-manager'
  spec.version       = VagrantPlugins::ServiceManager::VERSION
  spec.license       = 'GPL-2.0'
  spec.homepage      = 'https://github.com/projectatomic/vagrant-service-manager'
  spec.summary       = 'To provide the user a CLI to configure the ADB/CDK for different use cases and to provide '\
                        'glue between ADB/CDK and the user\'s developer environment.'
  spec.description   = 'Provides setup information, including environment variables and certificates, required to '\
                        'access services provided by ADB/CDK.'

  spec.authors       = ['Brian Exelbierd', 'Navid Shaikh']
  spec.email         = ['bex@pobox.com', 'nshaikh@redhat.com']

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']
end
