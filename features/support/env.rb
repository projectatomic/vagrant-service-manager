require 'aruba/cucumber'
require 'komenda'
require 'find'

###############################################################################
# Aruba config and Cucumber hooks
###############################################################################
Aruba.configure do |config|
  config.exit_timeout = 3600
  config.activate_announcer_on_command_failure = [:stdout, :stderr]
  config.working_directory = 'build/aruba'
end

Before do |scenario|
  @scenario_name = scenario.name
  ENV['VAGRANT_HOME'] = File.join(File.dirname(__FILE__), '..', '..', 'build', 'vagrant.d')
end

After do |_scenario|
  if File.exist?(File.join(aruba.config.working_directory, 'Vagrantfile'))
    #Komenda.run('bundle exec vagrant destroy -f', cwd: aruba.config.working_directory, fail_on_fail: true)
    if ENV.key?('CUCUMBER_RUN_PROVIDER')
      # if we have more than one provider we need to wait between scenarios in order to allow for
      # proper cleanup/shutdown of virtualization framework
      sleep 10
    end
  end

  # Remove the created Vagrant home dir
  # FileUtils.rmtree(ENV['VAGRANT_HOME']) if File.directory? ENV['VAGRANT_HOME']
end

###############################################################################
# Some helper functions
###############################################################################
# When running Vagrant from within a plugin development environment, Vagrant
# prints a warning which we can ignore
def stdout_without_plugin_context(raw_stdout)
  raw_stdout.lines.to_a[6..-1].join
end

def output_is_evaluable(raw_stdout)
  console_out = stdout_without_plugin_context(raw_stdout)
  console_out.each_line do |line|
    expect(line).to match(/^#.*|^export [a-zA-Z_]+=.*|^\n/)
  end
end

def output_is_script_readable(raw_stdout)
  console_out = stdout_without_plugin_context(raw_stdout)
  console_out.each_line do |line|
    expect(line).to match(/^[a-zA-Z_]+=.*$/)
  end
end

def extract_process_id(data)
  tokens = data.scan(/Main PID: ([0-9]+) \(/)
  tokens.last.first.to_i unless tokens.empty?
end

###############################################################################
# Some shared step definitions
##############################################################################
Given /provider is (.*)/ do |current_provider|
  requested_provider = ENV.key?('PROVIDER') ? ENV['PROVIDER'] : 'virtualbox'

  unless requested_provider.include?(current_provider)
    # puts "Skipping scenario '#{@scenario_name}' for provider '#{current_provider}', since this
    # provider is not explicitly enabled via environment variable 'PROVIDER'"
    skip_this_scenario
  end
end

Given /box is (.*)/ do |current_box|
  requested_box = ENV.key?('BOX') ? ENV['BOX'] : 'adb'

  unless requested_box.include?(current_box)
    # puts "Skipping scenario '#{@scenario_name}' for box '#{current_box}', since this box is not explicitly
    # enabled via environment variable 'BOX'"
    skip_this_scenario
  end
end

Then(/^stdout from "([^"]*)" should be evaluable in a shell$/) do |cmd|
  output_is_evaluable(aruba.command_monitor.find(Aruba.platform.detect_ruby(cmd)).send(:stdout))
end

Then(/^stdout from "([^"]*)" should be script readable$/) do |cmd|
  output_is_script_readable(aruba.command_monitor.find(Aruba.platform.detect_ruby(cmd)).send(:stdout))
end

Then(%r{^stdout from "([^"]*)" should match /(.*)/$}) do |cmd, regexp|
  aruba.command_monitor.find(Aruba.platform.detect_ruby(cmd)).send(:stdout) =~ /#{regexp}/
end

# track service process ID
@service_current_process_id = -1

# Note: Only for services supported through systemctl. Not for 'kubernetes'.
Then(/^the service "([^"]*)" should be ([^"]*)$/) do |service, operation|
  run("vagrant ssh -c \"sudo systemctl status #{service}\"")

  if %w(running restarted).include? operation
    exit_code = 0
    regexp = /Active: active \(running\)/
  elsif operation == 'stopped'
    exit_code = 3
    regexp = /Active: inactive\(dead\)/
  end

  expect(last_command_started).to have_exit_status(exit_code)
  aruba.command_monitor.find(Aruba.platform.detect_ruby(last_command_started)).send(:stdout) =~ regexp
end

# Note: Only for services supported through systemctl. Not for 'kubernetes'.
When(/^the "([^"]*)" service is( not)? running$/) do |service, negated|
  run("vagrant ssh -c \"sudo systemctl status #{service}\"")

  if negated
    expect(last_command_started).to have_exit_status(3)
  else
    expect(last_command_started).to have_exit_status(0)
    stdout = aruba.command_monitor.find(Aruba.platform.detect_ruby(last_command_started)).send(:stdout)
    @service_current_process_id = extract_process_id(stdout)
  end
end

# Note: Only for services supported through systemctl. Not for 'kubernetes'.
When(/^the "([^"]*)" service is \*not\* running$/) do |service|
  # Stop the service
  run("vagrant ssh -c \"sudo systemctl stop #{service}\"")

  expect(last_command_started).to have_exit_status(0)
  step 'the "docker" service is not running'
end

# Note: Only for services supported through systemctl. Not for 'kubernetes'.
Then(/^have a new pid for "([^"]*)" service$/) do |service|
  run("vagrant ssh -c \"sudo systemctl status #{service}\"")

  expect(last_command_started).to have_exit_status(0)
  stdout = aruba.command_monitor.find(Aruba.platform.detect_ruby(last_command_started)).send(:stdout)
  expect(@service_current_process_id).not_to eq(extract_process_id(stdout))
end

Then(/^the binary "([^"]*)" should be installed$/) do |binary|
  binaries = []
  Find.find("#{ENV['VAGRANT_HOME']}/data/service-manager/bin") do |path|
    binaries << path if path =~ %r{.*\/#{Regexp.quote(binary)}$} && File.file?(path)
  end

  expect(binaries.size).to eq(1)
  expect(File.executable?(binaries[0])).to eq(true)
end
