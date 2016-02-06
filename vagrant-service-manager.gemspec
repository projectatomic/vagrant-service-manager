Gem::Specification.new do |spec|
  spec.name          = 'vagrant-service-manager'
  spec.version       = '0.0.1'
  spec.homepage      = 'https://github.com/bexelbie/vagrant-service-manager'
  spec.summary       = "To provide the user a CLI to configure the ADB/CDK for different use cases and to provide glue between ADB/CDK and the user's developer environment."

  spec.authors       = ['Brian Exelbierd', 'Navid Shaikh']
  spec.email         = ['bex@pobox.com', 'nshaikh@redhat.com']

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
end
