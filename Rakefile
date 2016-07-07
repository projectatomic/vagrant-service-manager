require 'bundler/gem_tasks'
require 'rake/clean'
require 'cucumber/rake/task'
require 'mechanize'
require 'fileutils'
require 'yaml'
require 'launchy'
require 'date'

CLOBBER.include('pkg')
CLEAN.include('build')

BOX_DIR='.boxes'

task :init do
  FileUtils.mkdir_p 'build'
end

desc 'Removes all cached box files'
task :clean_boxes do
  FileUtils.rmtree '.boxes'
end

Cucumber::Rake::Task.new(:features)
task :features => [:clean, :init, :get_boxes]

namespace :features do
  desc 'Opens the HTML Cucumber test report'
  task :open_report do
    Launchy.open('./build/features_report.html')
  end
end

desc 'Download the required Vagrant boxes for the Cucumber tests'
task :get_boxes => :init do
  box_dir = File.join(File.dirname(__FILE__), BOX_DIR)

  requested_providers =  ENV.has_key?('PROVIDER') ? ENV['PROVIDER'].split(',').collect(&:strip) : ['virtualbox']
  requested_boxes =  ENV.has_key?('BOX') ? ENV['BOX'].split(',').collect(&:strip) : ['adb']
  nightly_cdk_builds = ENV.has_key?('NIGHTLY') ? ENV['NIGHTLY'].eql?('true') : false

  download_tasks = requested_boxes.map do |box|
    requested_providers.map do |provider|
      case box
        when 'cdk'
          if nightly_cdk_builds
            NightlyCDKDownloader.new(box_dir, provider)
          else
            PublicCDKDownloader.new(box_dir, provider)
          end
        when 'adb'
          ADBDownloader.new(box_dir, provider)
        else
          raise "Unknown provider #{provider}"
      end
    end
  end.flatten!

  threads = download_tasks.map do |task|
    Thread.new do
      task.execute
    end
  end

  while threads.any?(&:alive?) do
    pinwheel = %w{| / - \\}
    4.times do
      print "\b" + pinwheel.rotate!.first
      sleep(0.3)
    end
  end
end

# Helper classes for handling of Vagrant box downloading
class DownloadTask
  attr_reader :provider
  attr_reader :box_dir
  attr_reader :agent
  attr_reader :meta

  def initialize(box_dir, provider)
    unless File.directory?(box_dir)
      FileUtils.mkdir_p(box_dir)
    end
    @box_dir = box_dir
    @provider = provider

    @meta_file_name = File.join(box_dir, "#{name}-#{provider}.yml")
    @meta = read_meta

    @agent = Mechanize.new
    @agent.follow_meta_refresh = true
    @agent.ignore_bad_chunking = true
  end

  def needed?
    true
  end

  def execute
    download if needed?
  end

  def download
  end

  def name
    raise 'Needs to be overridden'
  end

  def box_file
    File.join(box_dir, "#{name}-#{provider}.box")
  end

  def read_meta
    if File.exist?(@meta_file_name)
      YAML.load_file(@meta_file_name)
    else
      {}
    end
  end

  def save_meta
    File.open(@meta_file_name, 'w+') do |file|
      file.write(meta.to_yaml)
    end
  end
end

class ADBDownloader < DownloadTask
  ADB_DOWNLOAD_URL='http://cloud.centos.org/centos/7/atomic/images'
  ADB_BOX_BASE_NAME='AtomicDeveloperBundle'

  def initialize(box_dir, provider)
    super(box_dir, provider)
  end

  def needed?
    latest_version = versions[-1]
    if meta.fetch(:current_version, nil).eql?(latest_version) && File.file?(box_file)
      puts "Using existing ADB box (version #{latest_version}) in #{box_dir}"
      return false
    else
      File.delete(box_file) if File.exist?(box_file)
      meta[:current_version] = latest_version
      save_meta
      true
    end
  end

  def download
    agent.get(ADB_DOWNLOAD_URL) do |page|
      page.links.each do |link|
        if link.href =~ /#{Regexp.quote(ADB_BOX_BASE_NAME)}-#{Regexp.quote(@meta[:current_version])}-CentOS7-#{Regexp.quote(provider)}.box/i
          agent.pluggable_parser.default = Mechanize::Download
          puts "Downloading ADB box #{ADB_DOWNLOAD_URL}/#{link.href}"
          agent.get(link.href).save(box_file)
        end
      end
    end
  end

  def name
    'adb'
  end

  private

  def versions
    agent.get(ADB_DOWNLOAD_URL) do |page|
      return page.links.select { |link| link.href =~ /#{Regexp.quote(ADB_BOX_BASE_NAME)}.*/ }
                 .map { |link| link.href.match(/^.*-(\d+\.\d+.\d+)-.*/i).captures[0] }
                 .uniq
                 .sort
    end
  end
end

class NightlyCDKDownloader < DownloadTask
  CDK_DOWNLOAD_URL_NIGHTLY='http://cdk-builds.usersys.redhat.com/builds/nightly'

  def initialize(box_dir, provider)
    super(box_dir, provider)
  end

  def needed?
    latest_version = versions[-1]
    if meta.fetch(:current_version, nil).eql?(latest_version) && File.file?(box_file)
      puts "Using existing CDK box (from #{latest_version}) in #{box_dir}"
      return false
    else
      File.delete(box_file) if File.exist?(box_file)
      meta[:current_version] = latest_version
      save_meta
      true
    end
  end

  def download
    download_base_url = "#{CDK_DOWNLOAD_URL_NIGHTLY}/#{meta[:current_version]}"
    agent.get(download_base_url) do |page|
      page.links.each do |link|
        if link.href.match(/.*#{Regexp.quote(provider)}.box$/)
          agent.pluggable_parser.default = Mechanize::Download
          puts "Downloading #{download_base_url}/#{link.href}"
          agent.get(link.href).save(box_file)
        end
      end
    end
  end

  def name
    'cdk'
  end

  private

  def versions
    agent.get(CDK_DOWNLOAD_URL_NIGHTLY) do |page|
      return page.links.select { |link| link.href =~ /\d{1,2}-[a-zA-Z]{3}-\d{4}/ }
                 .map { |link| link.href.chomp('/') }
                 .sort {|a,b| DateTime.strptime(a, '%d-%b-%Y') <=> DateTime.strptime(b, '%d-%b-%Y')}
    end
  end
end

class PublicCDKDownloader < DownloadTask
  CDK_DOWNLOAD_URL='https://access.redhat.com/downloads/content/293/ver=2.1/rhel---7/2.1.0/x86_64/product-software'
  CDK_BOX_BASE_NAME='rhel-cdk-kubernetes-7.2-25.x86_64.vagrant'
  LATEST_VERSION='v. 2.1.0 for x86_64'

  def initialize(box_dir, provider)
    super(box_dir, provider)
  end

  def needed?
    if meta.fetch(:current_version, nil).eql?(LATEST_VERSION) && File.file?(box_file)
      puts "Using existing public releaase CDK box (version #{LATEST_VERSION}) in #{box_dir}"
      return false
    else
      File.delete(box_file) if File.exist?(box_file)
      meta[:current_version] = LATEST_VERSION
      save_meta
      true
    end
  end

  def download
    agent.get(CDK_DOWNLOAD_URL) do |page|
      # Submit first form which is the redirect to login page form
      login_page = page.forms.first.submit

      # Submit the login form
      after_login = login_page.form_with(:id => 'kc-form-login') do |f|
        username_field = f.field_with(:id => 'username')
        username_field.value = 'service-manager@mailinator.com'
        password_field = f.field_with(:id => 'password')
        password_field.value = 'service-manager'
      end.click_button

      # There is one more redirect after successful login
      download_page = after_login.forms.first.submit

      download_page.links.each do |link|
        if link.href =~ /#{Regexp.quote(CDK_BOX_BASE_NAME)}-#{Regexp.quote(provider)}.box/
          agent.pluggable_parser.default = Mechanize::Download
          puts "Downloading public release CDK #{link.href}"
          agent.get(link.href).save(box_file)
        end
      end
    end
  end

  def name
    'cdk'
  end
end


