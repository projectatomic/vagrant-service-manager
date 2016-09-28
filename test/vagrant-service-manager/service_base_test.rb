require_relative '../test_helper'
require 'vagrant-service-manager/config'
require 'vagrant-service-manager/plugin_util'

module VagrantPlugins
  describe ServiceManager::ServiceBase do
    let(:machine) { fake_machine }
    let(:instance) { ServiceManager::ServiceBase.new(machine, machine.env) }

    it 'should build the proxy options if only proxy url is given' do
      machine.config.servicemanager.http_proxy = 'foo:8080'
      options = instance.proxy_cmd_options
      assert_match(/HTTP_PROXY='foo:8080'/, options)
    end

    it 'should build the proxy options if all proxy settings are given' do
      machine.config.servicemanager.http_proxy = 'foo:8080'
      machine.config.servicemanager.http_proxy_user = 'user'
      machine.config.servicemanager.http_proxy_password = 'password'

      options = instance.proxy_cmd_options
      assert_match(/HTTP_PROXY='foo:8080'/, options)
      assert_match(/HTTP_PROXY_USER='user'/, options)
      assert_match(/HTTP_PROXY_PASSWORD='password'/, options)
    end

    it 'should return empty proxy options if proxy url is not given' do
      machine.config.servicemanager.http_proxy_user = 'user'
      machine.config.servicemanager.http_proxy_password = 'password'

      options = instance.proxy_cmd_options
      assert_match(options, '')
    end

    it 'should return empty proxy options if user name not given' do
      machine.config.servicemanager.http_proxy = 'foo:8080'
      machine.config.servicemanager.http_proxy_password = 'password'

      options = instance.proxy_cmd_options
      assert_match(options, '')
    end

    it 'should return empty proxy options if password not given' do
      machine.config.servicemanager.http_proxy = 'foo:8080'
      machine.config.servicemanager.http_proxy_user = 'user'

      options = instance.proxy_cmd_options
      assert_match(options, '')
    end

    it 'should pass proxy settings as specified via Vagrant config' do
      machine.config.servicemanager.http_proxy = 'foo:8080'
      machine.config.servicemanager.http_proxy_user = 'user'
      machine.config.servicemanager.http_proxy_password = 'password'
      command = "#{instance.proxy_cmd_options} sccli openshift"

      ServiceManager::PluginUtil.execute_once(machine, FakeUI, command)

      command_executed = machine.communicate.commands[:sudo].first

      assert_match(/HTTP_PROXY='foo:8080'/, command_executed)
      assert_match(/HTTP_PROXY_USER='user'/, command_executed)
      assert_match(/HTTP_PROXY_PASSWORD='password'/, command_executed)
    end
  end
end
