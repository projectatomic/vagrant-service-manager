$LOAD_PATH.push(File.expand_path('../../plugins', __FILE__))
$LOAD_PATH.push(File.expand_path('../../lib', __FILE__))
$LOAD_PATH.push(File.expand_path('../../locales', __FILE__))

require 'bundler/setup'
require 'minitest/spec'
require 'minitest/autorun'
require 'mocha/mini_test'

require 'vagrant-service-manager'
# capibilities
require 'guests/redhat/cap/box_version'
require 'guests/redhat/cap/os_variant'
require_relative 'support/fake_ui'

def fake_environment(options = { enabled: true })
  { machine: fake_machine(options), ui: FakeUI }
end

class RecordingCommunicator
  attr_reader :commands, :responses

  def initialize
    @commands = Hash.new([])
    @responses = Hash.new('')
  end

  def stub_command(command, response)
    responses[command] = response
  end

  def sudo(command)
    commands[:sudo] << command
    responses[command]
  end

  def execute(command)
    commands[:execute] << command
    responses[command].split("\n").each do |line|
      yield(:stdout, "#{line}\n")
    end
  end

  def test(command)
    commands[:test] << command
    true
  end

  def ready?
    true
  end
end

module ServiceManager
  class FakeProvider
    def initialize(*args)
    end

    def _initialize(*args)
    end

    def ssh_info
    end

    def state
      @state ||= Vagrant::MachineState.new('fake-state', 'fake-state', 'fake-state')
    end
  end

  class FakeConfig
    def servicemanager
      @servicemanager_config ||= VagrantPlugins::ServiceManager::Config.new
    end

    def vm
      VagrantPlugins::Kernel_V2::VMConfig.new
    end
  end
end

def fake_machine(options = {})
  env = options.fetch(:env, Vagrant::Environment.new)

  machine = Vagrant::Machine.new(
    'fake_machine',
    'fake_provider',
    ServiceManager::FakeProvider,
    'provider_config',
    {},                             # provider_options
    env.vagrantfile.config,         # config
    Pathname('data_dir'),
    'box',
    options.fetch(:env, Vagrant::Environment.new),
    env.vagrantfile
  )

  machine.instance_variable_set('@communicator', RecordingCommunicator.new)
  machine.config.vm.hostname = options.fetch(:hostname, 'somehost.vagrant.test')
  machine
end

def test_data_dir_path
  File.expand_path('test_data', File.dirname(__FILE__))
end

module MiniTest
  class Spec
    alias hush capture_io
  end
end
