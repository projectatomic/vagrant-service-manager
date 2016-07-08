require 'bundler/gem_tasks'
require 'rake/clean'
require 'cucumber/rake/task'
require 'mechanize'
require 'fileutils'
require 'yaml'
require 'launchy'
require_relative 'download_task'

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

