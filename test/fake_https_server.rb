require 'webrick/https'

class FakeHTTPSServer < WEBrick::HTTPServer
  HTTPS_SERVER_DEFAULT_PORT = 8443
  CERT_NAME = [%w(CN localhost)].freeze

  def self.start(port = HTTPS_SERVER_DEFAULT_PORT)
    @https_server = FakeHTTPSServer.new(port)
    Thread.new do
      @https_server.start
    end

    @https_server
  end

  def self.stop
    @https_server.shutdown unless @https_server.nil?
  end

  def initialize(port)
    # we need to temporarily capture stderr, since WEBrick::Utils::create_self_signed_cert prints to stderr
    capture_stderr do
      @url_to_filename = {}
      @url_request_received = {}
      @log = StringIO.new
      logger = WEBrick::Log.new(@log)
      access_log = [[@log, 'STATUS=%s URL=%{url}n BODY=%{body}n']]
      super(Port: port, SSLEnable: true, SSLCertName: CERT_NAME, Logger: logger, AccessLog: access_log)
    end
  end

  def service(req, res)
    uri = req.request_uri.to_s
    return unless @url_to_filename.key?(uri)
    @url_request_received[uri] = true
    res.content_type = 'application/octet-stream'

    open(@url_to_filename[uri], 'r') do |file|
      file.write(res.body)
    end
  end

  def expect_and_respond(url, filename)
    @url_to_filename[url] = filename
    @url_request_received[url] = false
  end

  def assert_requests
    @url_request_received.values.reduce do |memo, received|
      memo && received
    end
  end

  private

  def capture_stderr
    # The output stream must be an IO-like object. In this case we capture it in
    # an in-memory IO object so we can return the string value. You can assign any
    # IO object here.
    previous_stderr = $stderr
    $stderr = StringIO.new
    yield
    $stderr.string
  ensure
    # Restore the previous value of stderr (typically equal to STDERR).
    $stderr = previous_stderr
  end
end
