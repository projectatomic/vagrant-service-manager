require 'net/http'

module VagrantPlugins
  module ServiceManager
    class URLValidationError < Vagrant::Errors::VagrantError
      error_key(:url_validation_error)
    end

    class BinaryHandler
      BINARY_ARCHIVE_FORMATS = ['.tgz', '.tar.gz', '.gz', '.zip'].freeze
      BINARY_NAME = {
        docker: 'docker', openshift: 'oc', kubernetes: 'kubectl'
      }.freeze
      VERSION_CMD = {
        docker: "docker version --format '{{.Server.Version}}'",
        openshift: "oc version | grep -oE 'oc v([0-9a-z.]+-?[a-z0-9]*.?[0-9])' | sed -E 's/oc v//'",
        kubernetes: %q(kubectl version --client | sed -E 's/(.*)v([0-9a-z.]+-?[a-z0-9]*.?[0-9]*)",(.*)/\2/')
      }.freeze
      BINARY_REGEX = {
        windows: { docker: %r{\/docker.exe$}, openshift: /oc.exe$/ },
        unix: { docker: %r{\/docker$}, openshift: /oc$/ }
      }.freeze
      ARCHIVE_MAP = {
        '.tgz' => 'Tar', '.tar.gz' => 'Tar', '.gz' => 'Tar', '.zip' => 'Zip'
      }.freeze
      LABEL = 'servicemanager.commands.install_cli.message'.freeze

      attr_accessor :path, :version, :type, :url,
                    :binary_exists, :skip_download, :archive_file_path

      def initialize(machine, env, options)
        @machine = machine
        @ui = env.ui
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

      def build_archive_path
        @archive_file_path = "#{@temp_bin_dir}/#{File.basename(@url)}"
      end

      def ensure_binary_and_temp_directories
        FileUtils.mkdir_p(bin_dir) unless File.directory?(bin_dir)
        FileUtils.mkdir_p(@temp_bin_dir) unless File.directory?(@temp_bin_dir)
      end

      def download_archive
        return @skip_download = true if File.exist?(@archive_file_path)
        Vagrant::Util::Downloader.new(@url, @archive_file_path).download!
      rescue Vagrant::Errors::DownloaderError => e
        @ui.error e.message
        exit 126
      end

      def prepare_binary
        tmp_binary_file_path = @archive_file_path

        # If binary is in archive format, extract it
        if binary_archived?
          tmp_binary_file_path = "#{archive_dir_name}/#{binary_name}"
          unless File.file? tmp_binary_file_path
            archive_handler_class.new(@archive_file_path, tmp_binary_file_path, file_regex).unpack
          end
        end

        FileUtils.cp(tmp_binary_file_path, @path)
        File.chmod(0o755, @path)
      rescue StandardError => e
        @ui.error e.message
        exit 126
      end

      def print_message
        bin_path = PluginUtil.format_path(@path)
        @ui.info I18n.t(LABEL,
                        path: bin_path, dir: File.dirname(bin_path), service: @type,
                        binary: binary_name, when: (@binary_exists ? 'already' : 'now'))
      end

      def handle_windows_binary_path
        return if @type != :openshift

        if @options[:box_version] == 'cdk'
          oc_version = CDKOpenshiftBinaryHandler::LATEST_OC_VERSION
        end

        unless @options['--cli-version'] != oc_version || @options['--path']
          path = PluginUtil.fetch_existing_oc_binary_path_in_windows
          @path = path unless path.nil?
        end
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
        req.use_ssl = true if url.scheme == 'https'
        res = req.request_head(url.path)

        unless %w(200 302).include? res.code
          raise URLValidationError, I18n.t('servicemanager.commands.install_cli.url_validation_error')
        end

        true
      end

      private

      def binary_archived?
        BINARY_ARCHIVE_FORMATS.include? File.extname(@archive_file_path)
      end

      def archive_handler_name
        ARCHIVE_MAP[File.extname(@url)] + 'Handler'
      end

      def binary_path
        "#{ServiceManager.bin_dir}/#{@type}/#{@version}/#{binary_name}"
      end
    end
  end
end
