require 'bundler/gem_tasks'
require 'rake/clean'
require 'mechanize'
require 'fileutils'

CLOBBER.include('pkg')
CLEAN.include('build')

desc 'Download Vagrant box'
task :getbox, [:provider] do |t, args|
  if args[:provider].nil?
    provider='virtualbox'
  else
    provider=args[:provider]
  end
  agent = Mechanize.new
  agent.follow_meta_refresh = true
  agent.get('https://access.redhat.com/downloads/content/293/ver=2/rhel---7/2.0.0/x86_64/product-software') do |page|

    # Submit first form which is the redirect to login page form
    login_page = page.forms.first.submit

    # Submit the login form
    after_login = login_page.form_with(:name => 'login_form') do |f|
     username_field = f.field_with(:id => 'username')
     username_field.value = ENV['REDHAT_USER']
     password_field = f.field_with(:id => 'password')
     password_field.value = ENV['REDHAT_PASSWORD']
    end.click_button

    # There is one more redirect afte successful login
    download_page = after_login.forms.first.submit

    download_page.links.each do |link|
     if link.href =~ /rhel-cdk-kubernetes-7.2-23.x86_64.vagrant-#{Regexp.quote(provider)}.box/
      puts "Downloading box #{link.href}"
      download_dir = File.join(File.dirname(__FILE__), 'build', 'tmp')
      unless File.directory?(download_dir)
       FileUtils.mkdir_p(download_dir)
      end
      agent.pluggable_parser.default = Mechanize::Download
      agent.get(link.href).save(File.join(download_dir, 'cdk.box'))
     end
    end
  end
end

desc 'Run acceptance specs using vagrant-spec'
task :acceptance, [:provider] do |t, args|
  if args[:provider].nil?
    provider='virtualbox'
  else
    provider=args[:provider]
  end
  build_dir = File.join(File.dirname(__FILE__), 'build')
  unless File.directory?(build_dir)
    FileUtils.mkdir_p(build_dir)
  end
  components = %w(
    cdk
  ).map{|s| "provider/#{provider}/#{s}" }
  sh "export VAGRANT_SPEC_PROVIDER=#{provider} && bundle exec vagrant-spec test --components=#{components.join(' ')} | tee build/spec.log"
end
