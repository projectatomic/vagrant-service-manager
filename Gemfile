source 'https://rubygems.org'

group :development do
  gem 'vagrant',
      git: 'https://github.com/mitchellh/vagrant.git',
      ref: 'v1.8.4'
  gem 'mechanize'
  gem 'json'
  gem 'cucumber', '~> 2.1'
  gem 'aruba', '~> 0.13'
  gem 'komenda', '~> 0.1.6'
  gem 'launchy'
  gem 'rake', '10.4.2'
  gem 'rubocop', '0.44.1'
  gem 'guard-rake'
  gem 'guard-livereload', '~> 2.5', require: false
  gem 'asciidoctor'
end

group :test do
  gem 'minitest'
  gem 'mocha'
end

group :plugins do
  gemspec
  gem 'vagrant-libvirt'              if RUBY_PLATFORM =~ /linux/i
  gem 'fog-libvirt', '0.0.3'         if RUBY_PLATFORM =~ /linux/i # https://github.com/pradels/vagrant-libvirt/issues/568
end
