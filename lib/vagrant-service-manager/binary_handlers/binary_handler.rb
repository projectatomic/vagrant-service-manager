require 'net/http'

module VagrantPlugins
  module ServiceManager
    class URLValidationError < Vagrant::Errors::VagrantError
      error_key(:url_validation_error)
    end

    class BinaryHandler
      BINARY_ARCHIVE_FORMATS = ['.tgz', '.tar.gz', '.gz', '.zip'].freeze
      BINARY_NAME = {
        docker: 'docker', openshift: 'oc'
      }.freeze
      VERSION_CMD = {
        docker: "docker version --format '{{.Server.Version}}'",
        openshift: "oc version | grep 'oc' | grep -oE '[0-9.]+'"
      }.freeze
      BINARY_REGEX = {
        windows: { docker: %r{\/docker.exe$}, openshift: %r{oc.exe$} },
        unix: { docker: %r{\/docker$}, openshift: %r{oc$} }
      }.freeze
      ARCHIVE_MAP = {
        '.tgz' => 'Tar', '.tar.gz' => 'Tar', '.gz' => 'Tar', '.zip' => 'Zip'
      }.freeze
      LABEL = 'servicemanager.commands.install_cli.message'.freeze

      attr_accessor :path, :version, :type, :url,
                    :binary_exists, :skip_download, :archive_file_path

      def initialize(machine, env, options)
        @machine = machine
        @ui      = env.ui
        @url = ''
        @binary_exists = true
        @skip_download = false
        @archive_file_path = ''
        @options = options
        @type = options[:type]
        @version = options['--cli-version'] || PluginUtil.execute_once(@machine, @ui, VERSION_CMD[@type])
        @path = options['--path'] || binary_path
        @temp_bin_dir = "#{ServiceManager.temp_dir}/#{@type}"
      end

      def install
        build_download_url
        validate_url
        build_archive_path
        ensure_binary_and_temp_directories
        download_archive
        prepare_binary
      end

      def build_download_url
      end

      def build_archive_path
      end

      def ensure_binary_and_temp_directories
      end

      def download_archive
      end

      def prepare_binary
      end

      def print_message
      end

      def archive_dir_name
        @archive_file_path.sub(Regexp.new(BINARY_ARCHIVE_FORMATS.join('|')), '')
      end

      def archive_handler_class
        Object.const_get("#{ServiceManager.name}::#{archive_handler_name}")
      end

      def binary_name
        BINARY_NAME[@type] + binary_ext
      end

      def binary_ext
        Vagrant::Util::Platform.windows? ? '.exe' : ''
      end

      def bin_dir
        File.dirname(@path)
      end

      def file_regex
        os_type = Vagrant::Util::Platform.windows? ? :windows : :unix
        BINARY_REGEX[os_type][@type]
      end

      # Checks if url is accessible or not
      def validate_url
        url = URI.parse(@url)
        req = Net::HTTP.new(url.host, url.port)
        res = req.request_head(url.path)

        unless res.code == '200'
          raise URLValidationError, I18n.t('servicemanager.commands.install_cli.url_validation_error')
        end
      end

      private

      def archive_handler_name
        ARCHIVE_MAP[File.extname(@url)] + 'Handler'
      end

      def binary_path
        "#{ServiceManager.bin_dir}/#{@type}/#{@version}/#{binary_name}"
      end
    end
  end
end
