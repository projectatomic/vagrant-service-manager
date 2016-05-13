source 'https://rubygems.org'

gemspec

group :development do
  gem 'vagrant',      git: 'https://github.com/mitchellh/vagrant.git'
  gem 'rake'
  gem 'vagrant-libvirt'
  gem 'fog-libvirt', '0.0.3' # https://github.com/pradels/vagrant-libvirt/issues/568
  gem 'mechanize'
  gem 'json'
  gem 'cucumber', '~> 2.1'
  gem 'aruba', '~> 0.13'
  gem 'komenda', '~> 0.1.6'
  gem 'launchy'
end

group :plugins do
  gem 'vagrant-service-manager', path: '.'
end
