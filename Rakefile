require 'bundler/gem_tasks'
require 'rake/clean'
require 'cucumber/rake/task'
require 'mechanize'
require 'fileutils'
require 'yaml'
require 'launchy'
require 'rake/testtask'

CDK_DOWNLOAD_URL='https://access.redhat.com/downloads/content/293/ver=2/rhel---7/2.0.0/x86_64/product-software'
CDK_BOX_BASE_NAME='rhel-cdk-kubernetes-7.2-23.x86_64.vagrant'

CDK_DOWNLOAD_URL_NIGHTLY='http://cdk-builds.usersys.redhat.com/builds/nightly/latest-build'

ADB_DOWNLOAD_URL='http://cloud.centos.org/centos/7/atomic/images'
ADB_BOX_BASE_NAME='AtomicDeveloperBundle-2.1.0-CentOS7'

CLOBBER.include('pkg')
CLEAN.include('build')

task :init do
  FileUtils.mkdir_p 'build'
end

task :clean_for_testing do
  FileUtils.rm_rf ['build/aruba', 'build/vagrant.d', 'build/features_report.html']
end

# Default unit test task
desc 'Run all unit tests'
Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_test.rb'
  t.libs << 'test'
end

# Cucumber acceptance test tasks
Cucumber::Rake::Task.new(:features)
task :features => [:init, :clean_for_testing]

namespace :features do
  desc 'Opens the HTML Cucumber test report'
  task :open_report do
    Launchy.open('./build/features_report.html')
  end
end

desc 'Download latest publicly released / latest nightly build of CDK Vagrant box using the specified provider (default \'virtualbox\', \'false\')'
task :get_cdk, [:provider, :nightly] do |t, args|
  provider = args[:provider].nil? ? 'virtualbox' : args[:provider]
  use_nightly = args[:nightly].nil? ? false : !!(args[:nightly] =~ /true/)
  agent = Mechanize.new
  agent.follow_meta_refresh = true

  if use_nightly
    agent.ignore_bad_chunking = true
    agent.get(CDK_DOWNLOAD_URL_NIGHTLY) do |page|
      page.links.each do |link|
        if link.href.match(/.*#{Regexp.quote(provider)}.box$/)
          download_dir = File.join(File.dirname(__FILE__), 'build', 'boxes')
          unless File.directory?(download_dir)
            FileUtils.mkdir_p(download_dir)
          end
          agent.pluggable_parser.default = Mechanize::Download
          puts "Downloading #{CDK_DOWNLOAD_URL_NIGHTLY}/#{link.href}"
          agent.get(link.href).save(File.join(download_dir, "cdk-#{provider}.box"))
        end
      end
    end
  else
    agent.get(CDK_DOWNLOAD_URL) do |page|

      # Submit first form which is the redirect to login page form
      login_page = page.forms.first.submit

      # Submit the login form
      after_login = login_page.form_with(:name => 'login_form') do |f|
        username_field = f.field_with(:id => 'username')
        username_field.value = 'service-manager@mailinator.com'
        password_field = f.field_with(:id => 'password')
        password_field.value = 'service-manager'
      end.click_button

      # There is one more redirect after successful login
      download_page = after_login.forms.first.submit

      download_page.links.each do |link|
        if link.href =~ /#{Regexp.quote(CDK_BOX_BASE_NAME)}-#{Regexp.quote(provider)}.box/
          download_dir = File.join(File.dirname(__FILE__), 'build', 'boxes')
          unless File.directory?(download_dir)
            FileUtils.mkdir_p(download_dir)
          end
          agent.pluggable_parser.default = Mechanize::Download
          puts "Downloading #{link.href}"
          agent.get(link.href).save(File.join(download_dir, "cdk-#{provider}.box"))
        end
      end
    end
  end
end
task :get_cdk => :init

desc 'Download ADB Vagrant box using the specified provider (default \'virtualbox\')'
task :get_adb, [:provider] do |t, args|
  provider = args[:provider].nil? ? 'virtualbox' : args[:provider]
  agent = Mechanize.new
  agent.follow_meta_refresh = true
  agent.get(ADB_DOWNLOAD_URL) do |page|
    page.links.each do |link|
      if match = link.href.match(/#{Regexp.quote(ADB_BOX_BASE_NAME)}-(.*).box/)
        if  match.captures[0].downcase == provider
          download_dir = File.join(File.dirname(__FILE__), 'build', 'boxes')
          unless File.directory?(download_dir)
            FileUtils.mkdir_p(download_dir)
          end
          agent.pluggable_parser.default = Mechanize::Download
          puts "Downloading #{ADB_DOWNLOAD_URL}/#{link.href}"
          agent.get(link.href).save(File.join(download_dir, "adb-#{provider}.box"))
        end
      end
    end
  end
end
task :get_adb => :init
