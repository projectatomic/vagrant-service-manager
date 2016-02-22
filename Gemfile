source 'https://rubygems.org'

gemspec

group :development do
  gem 'vagrant', git: 'https://github.com/mitchellh/vagrant.git'
  # added as the vagrant component wouldn't build without it
  gem 'json'
  gem 'rake'
  gem 'bundler', '~> 1.6'
end

group :plugins do
  gem 'vagrant-service-manager', path: '.'
end
