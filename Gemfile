source 'https://rubygems.org'

gemspec

group :development do
  gem 'vagrant',
      git: 'git://github.com/mitchellh/vagrant.git',
      ref: 'v1.8.4'
  gem 'vagrant-libvirt'              if RUBY_PLATFORM =~ /linux/i
  gem 'fog-libvirt', '0.0.3'         if RUBY_PLATFORM =~ /linux/i # https://github.com/pradels/vagrant-libvirt/issues/568
end

group :plugins do
  gem 'vagrant-service-manager', path: '.'
end
