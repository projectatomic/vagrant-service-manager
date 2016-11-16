require 'webrick'
require 'webrick/https'
require 'webrick/httpproxy'
require 'webrick/httpstatus'

module WEBrick
  class BasicLog
    def log(_level, _data)
      @log = ''
    end
  end
end

class FakeHTTPProxyServer < WEBrick::HTTPProxyServer
  def initialize(options)
    @options = options
    @config = {
      Port: options[:port],
      Logger: WEBrick::Log.new(File.open(File::NULL, 'w')), # Logger and AccessLog is set to
      AccessLog: []                                         # log nothing
    }
    set_authenticated_config if options.key?(:authenticated)
    super(@config)
  end

  def service(req, res)
    if req.request_method == 'CONNECT'
      req.instance_variable_set(:@unparsed_uri, @options[:proxy_url])
      do_CONNECT(req, res)
    elsif req.unparsed_uri =~ %r{^http://}
      proxy_service(req, res)
    else
      super(req, res)
    end
  end

  private

  def set_authenticated_config
    htpasswd = WEBrick::HTTPAuth::Htpasswd.new @options[:htpasswd_file]
    htpasswd.set_passwd 'Proxy Realm', @options[:user], @options[:password]
    htpasswd.flush
    # Authenticator
    authenticator = WEBrick::HTTPAuth::ProxyBasicAuth.new(
      Realm: 'Proxy Realm', UserDB: htpasswd
    )
    @config[:ProxyAuthProc] = authenticator.method(:authenticate).to_proc
  end
end

# Fake HTTPS Server
class FakeHTTPSServer < WEBrick::HTTPServer
  CERT_NAME = [%w(CN localhost)].freeze
  OC_URI = 'https://github.com/openshift/origin/releases/download/v1.2.0/openshift-origin-client-tools-v1.2.0-2e62fab-linux-64bit.tar.gz'.freeze
  FAKE_OC_FILE = 'test/test_data/openshift-origin-client-tools-v1.2.0-2e62fab-linux-64bit/oc'.freeze

  def initialize(port, stream_log)
    logger = WEBrick::Log.new(stream_log, WEBrick::Log::INFO)
    access_log = [[stream_log, 'STATUS=%s URL=%{url}n BODY=%{body}n']]
    super(Port: port, SSLEnable: true, SSLCertName: CERT_NAME, Logger: logger, AccessLog: access_log)
  end

  def service(req, _res)
    return unless req.request_uri.to_s == OC_URI
    req.attributes['url'] = req.request_uri
    req.attributes['body'] = File.open(File.expand_path(FAKE_OC_FILE), 'r').read.chomp
  end
end
