require_relative '../test_helper'
require 'vagrant/util/downloader'

module VagrantPlugins
  module ServiceManager
    describe 'Proxy Test' do
      before do
        @machine = fake_machine
        @ui = FakeUI.new
        # set test path
        @plugin_test_path = "#{@machine.env.data_dir}/service-manager/test"
        ServiceManager.temp_dir = "#{@plugin_test_path}/temp"
        ServiceManager.bin_dir = "#{@plugin_test_path}/bin"

        @stream_log = StringIO.new # Get logs for verification

        @https_server = nil
        https_server_port = 8443
        # Start Fake HTTPS Server
        Thread.new do
          @https_server = FakeHTTPSServer.new(https_server_port, @stream_log)
          @https_server.start
        end

        @configs = {
          port: 7000, htpasswd_file: "#{ServiceManager.temp_dir}/.htpasswd",
          proxy_url: "localhost:#{https_server_port}"
        }
      end

      after do
        FileUtils.rmtree(@plugin_test_path) if File.directory? @plugin_test_path
        @https_server.shutdown
      end

      describe 'Unauthenticated proxy environment' do
        before do
          @string_stream = StringIO.new
          @options = { type: :openshift, '--cli-version' => '1.2.0' }
          @handler = ADBOpenshiftBinaryHandler.new(@machine, @machine.env, @options)
          @handler.build_download_url
          @handler.validate_url
          @handler.build_archive_path
          @handler.ensure_binary_and_temp_directories
          ENV['CURL_INSECURE'] = 'true' # Allow insecure curl

          Thread.new do
            @proxy_server = FakeHTTPProxyServer.new @configs
            @proxy_server.start
          end

          @machine.config.servicemanager.proxy = "http://localhost:#{@configs[:port]}"
        end

        after do
          @proxy_server.shutdown
        end

        it 'should send client binary download request' do
          expected_result = "STATUS=200 URL=#{@handler.url} BODY=FAKE_OC"

          @handler.download_archive

          @stream_log.string.must_include expected_result
        end
      end

      describe 'Authenticated proxy environment' do
        before do
          @string_stream = StringIO.new
          @options = { type: :openshift, '--cli-version' => '1.2.0' }
          @handler = ADBOpenshiftBinaryHandler.new(@machine, @machine.env, @options)
          @handler.build_download_url
          @handler.validate_url
          @handler.build_archive_path
          @handler.ensure_binary_and_temp_directories
          ENV['CURL_INSECURE'] = 'true' # Allow insecure curl

          @configs = { user: 'user', password: 'password', authenticated: true }.merge(@configs)

          Thread.new do
            @proxy_server = FakeHTTPProxyServer.new @configs
            @proxy_server.start
          end

          @machine.config.servicemanager.proxy = "http://localhost:#{@configs[:port]}"
          @machine.config.servicemanager.proxy_user = @configs[:user]
          @machine.config.servicemanager.proxy_password = @configs[:password]
        end

        after do
          @proxy_server.shutdown
        end

        it 'should send client binary download request' do
          expected_result = "STATUS=200 URL=#{@handler.url} BODY=FAKE_OC"

          @handler.download_archive

          @stream_log.string.must_include expected_result
        end
      end
    end
  end
end
