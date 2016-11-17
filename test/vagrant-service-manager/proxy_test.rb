require_relative '../test_helper'
require 'vagrant/util/downloader'
require 'uri'

module VagrantPlugins
  module ServiceManager
    describe 'Proxy Test' do
      before do
        @machine = fake_machine

        # Set test path
        @plugin_test_path = "#{@machine.env.data_dir}/service-manager/test"
        ServiceManager.temp_dir = "#{@plugin_test_path}/temp"
        ServiceManager.bin_dir = "#{@plugin_test_path}/bin"

        # Allow insecure curl
        ENV['CURL_INSECURE'] = 'true'

        # Set up the handler under test
        options =  { type: :openshift, '--cli-version' => '1.2.0' }
        @handler = ADBOpenshiftBinaryHandler.new(@machine, @machine.env, options)
        @handler.build_download_url
        @handler.validate_url
        @handler.build_archive_path
        @handler.ensure_binary_and_temp_directories

        dirname = File.dirname(__FILE__)
        @filename = File.join(dirname, '..', 'test_data', URI(@handler.url).path.split('/').last.to_s)
      end

      after do
        FileUtils.rmtree(@plugin_test_path) if File.directory? @plugin_test_path
        FakeHTTPSServer.stop
        FakeHTTPProxyServer.stop
      end

      describe 'Unauthenticated proxy environment' do
        before do
          @http_proxy = FakeHTTPProxyServer.start ServiceManager.temp_dir
          @https_server = FakeHTTPSServer.start

          @machine.config.servicemanager.proxy = "http://localhost:#{FakeHTTPProxyServer::DEFAULT_PORT}"
        end

        it 'client binary download request should pass through proxy' do
          @http_proxy.expect_http_connect('github.com:443')
          @https_server.expect_and_respond(@handler.url, @filename)

          @handler.download_archive

          @http_proxy.assert_connect_requests.must_equal true
          @https_server.assert_requests.must_equal true
        end
      end

      describe 'Authenticated proxy environment' do
        before do
          @http_proxy = FakeHTTPProxyServer.start(ServiceManager.temp_dir,
                                                  FakeHTTPProxyServer::DEFAULT_PORT, true)
          @https_server = FakeHTTPSServer.start

          @machine.config.servicemanager.proxy = "http://localhost:#{FakeHTTPProxyServer::DEFAULT_PORT}"
          @machine.config.servicemanager.proxy_user = 'user'
          @machine.config.servicemanager.proxy_password = 'password'
        end

        it 'client binary download request should pass through proxy' do
          @http_proxy.expect_http_connect('github.com:443')
          @https_server.expect_and_respond(@handler.url, @filename)

          @handler.download_archive

          @http_proxy.assert_connect_requests.must_equal true
          @https_server.assert_requests.must_equal true
        end
      end
    end
  end
end
