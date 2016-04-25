source 'https://rubygems.org'

gemspec

group :development do
  gem 'vagrant',      git: 'https://github.com/mitchellh/vagrant.git'
  gem 'vagrant-spec', git: 'https://github.com/mitchellh/vagrant-spec.git'
  gem 'gem-compare'
  gem 'rake'
  gem 'vagrant-vbguest'
  gem 'vagrant-libvirt'
  gem 'fog-libvirt', '0.0.3' # https://github.com/pradels/vagrant-libvirt/issues/568
  gem 'mechanize'

  # added as the vagrant component wouldn't build without it
  gem 'json'
end

group :plugins do
  gem 'vagrant-service-manager', path: '.'
  gem 'vagrant-registration'
end
