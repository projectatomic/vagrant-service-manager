module VagrantPlugins
  module ServiceManager
    class Installer
      LABEL = 'servicemanager.commands.install_cli.message'
      TEMP_DIR = '/tmp'
      BINARY_NAME = {
        docker: 'docker', openshift: 'oc'
      }

      def initialize(type, machine, env, options)
        @type = type
        @machine = machine
        @ui = env.ui
        @options = options

        @binary_exists = true
        @version = options['--cli-version'] || PluginUtil.execute_once(@machine, @ui, VERSION_CMD[@type])
        @path = options['--path']
        @binary_name = BINARY_NAME[@type]
        @temp_bin_dir = "#{TEMP_DIR}/#{@type.to_s}"
        @url = ''
      end

      def install
        puts "I m install now...."
        build_binary_path

        unless PluginUtil.binary_downloaded?(@path)
          build_download_url
          puts "url: #{@url}"
          ensure_binary_and_temp_directories
          download_and_prepare_binary
        end
      end

      def print_message
        @ui.info I18n.t(LABEL, path: @path, dir: File.dirname(@path),
                        binary: @binary_name, when: (@binary_exists ? 'already' : 'now'))
      end

      def build_binary_path
        @path = "#{ServiceManager.bin_dir}/#{@type.to_s}/#{@version}/#{@binary_name}" if @path.nil?
      end

      def build_download_url
      end

      def ensure_binary_and_temp_directories
      end

      def download_and_prepare_binary
      end
    end
  end
end
