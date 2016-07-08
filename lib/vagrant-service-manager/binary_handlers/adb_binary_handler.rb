module VagrantPlugins
  module ServiceManager
    class ADBBinaryHandler < BinaryHandler
      def initialize(machine, env, options)
        super(machine, env, options)
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
          archive_handler_class.new(@archive_file_path, tmp_binary_file_path, file_regex).unpack
        end

        FileUtils.cp(tmp_binary_file_path, @path)
        File.chmod(0755, @path)
      rescue StandardError => e
        @ui.error e.message
        exit 126
      end

      def print_message
        binary_path = PluginUtil.format_path(@path)
        @ui.info I18n.t(LABEL,
                        path: binary_path, dir: File.dirname(binary_path), service: @type,
                        binary: binary_name, when: (@binary_exists ? 'already' : 'now'))
      end

      private

      def binary_archived?
        BINARY_ARCHIVE_FORMATS.include? File.extname(@archive_file_path)
      end
    end
  end
end
