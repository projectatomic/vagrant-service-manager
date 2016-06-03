module VagrantPlugins
  module ServiceManager
    class ADBOpenshiftBinaryHandler < ADBBinaryHandler
      OC_BINARY_BASE_URL = 'https://github.com/openshift/origin/releases'.freeze
      OC_FILE_PREFIX = 'openshift-origin-client-tools'.freeze

      def initialize(machine, env, options)
        super(machine, env, options)
      end

      def build_download_url
        download_base_path = "#{OC_BINARY_BASE_URL}/download/v#{@version}/"
        file = "#{OC_FILE_PREFIX}-v#{@version}-#{version_sha}-#{archive_ext}"
        @url = download_base_path + file
      end

      private

      def version_sha
        tag_url = "#{OC_BINARY_BASE_URL}/tag/v#{@version}"
        data = Net::HTTP.get(URI(tag_url))
        tokens = data.match("-v#{@version}-(.*)-#{archive_ext}").captures
        tokens.first unless tokens.empty?
      rescue StandardError => e
        @ui.error e.message
        exit 126
      end

      def os_type
        if Vagrant::Util::Platform.windows?
          'windows'
        elsif Vagrant::Util::Platform.linux?
          'linux'
        elsif Vagrant::Util::Platform.darwin?
          'mac'
        end
      end

      def arch
        arch = @machine.env.host.capability(:os_arch)
        arch == 'x86_64' ? '64' : '32'
      end

      def archive_ext
        os_type + (os_type == 'linux' ? "-#{arch}bit.tar.gz" : '.zip')
      end
    end
  end
end
