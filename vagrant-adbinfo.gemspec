Gem::Specification.new do |spec|
  spec.name          = 'vagrant-adbinfo'
  spec.version       = '0.1.0.cdk'
  spec.homepage      = 'https://github.com/bexelbie/vagrant-adbinfo'
  spec.summary       = 'Vagrant plugin that provides the IP address:port and TLS certificate file location for a docker daemon'

  spec.authors       = ['Brian Exelbierd', 'Navid Shaikh']
  spec.email         = ['bex@pobox.com', 'nshaikh@redhat.com']

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
end
