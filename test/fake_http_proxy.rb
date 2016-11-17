require 'webrick'
require 'webrick/https'
require 'webrick/httpproxy'
require 'webrick/httpstatus'

require_relative 'fake_https_server'

class FakeHTTPProxyServer < WEBrick::HTTPProxyServer
  DEFAULT_PORT = 7000

  def self.start(tmp_dir, port = DEFAULT_PORT, authenticated = false)
    @proxy_server = FakeHTTPProxyServer.new(tmp_dir, port, authenticated)
    Thread.new do
      @proxy_server.start
    end

    @proxy_server
  end

  def self.stop
    @proxy_server.shutdown unless @proxy_server.nil?
  end

  def initialize(tmp_dir, port, authenticated)
    @fake_https_server = "localhost:#{FakeHTTPSServer::HTTPS_SERVER_DEFAULT_PORT}"
    @connect_request_received = {}
    @log = StringIO.new
    config = {
      Port: port,
      Logger: WEBrick::Log.new(@log),
      AccessLog: [[@log, WEBrick::AccessLog::COMBINED_LOG_FORMAT]]
    }
    if authenticated
      authenticator = WEBrick::HTTPAuth::ProxyBasicAuth.new(get_auth_options(tmp_dir))
      config[:ProxyAuthProc] = authenticator.method(:authenticate).to_proc
    end
    super(config)
  end

  def service(req, res)
    if req.request_method == 'CONNECT'
      # redirect HTTPS traffic to our fake HTTPS server
      @connect_request_received[req.unparsed_uri] = true if @connect_request_received.key? req.unparsed_uri
      req.instance_variable_set(:@unparsed_uri, @fake_https_server)
      do_CONNECT(req, res)
    elsif req.unparsed_uri =~ %r{^http://}
      proxy_service(req, res)
    else
      super(req, res)
    end
  end

  def expect_http_connect(host_and_port)
    @connect_request_received[host_and_port] = false
  end

  def assert_connect_requests
    @connect_request_received.values.reduce do |memo, received|
      memo && received
    end
  end

  private

  def get_auth_options(tmp_dir)
    htpasswd = WEBrick::HTTPAuth::Htpasswd.new File.join(tmp_dir, '.htpasswd')
    htpasswd.set_passwd 'Proxy Realm', 'user', 'password'
    htpasswd.flush
    {
      Realm:  'Proxy Realm',
      UserDB:  htpasswd,
      Logger:  WEBrick::Log.new(@log)
    }
  end
end
