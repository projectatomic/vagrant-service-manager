module VagrantPlugins
  module ServiceManager
    class ADBDockerBinaryHandler < ADBBinaryHandler
      # Refer https://docs.docker.com/v1.10/engine/installation/binaries
      DOCKER_BINARY_BASE_URL = 'https://get.docker.com/builds'.freeze

      def initialize(machine, env, options)
        super(machine, env, options)
      end

      def build_download_url
        arch = @machine.env.host.capability(:os_arch)
        @url = "#{DOCKER_BINARY_BASE_URL}/#{os_type}/#{arch}/docker-#{@version}#{archive_ext}"
      end

      private

      def os_type
        if Vagrant::Util::Platform.windows?
          'Windows'
        elsif Vagrant::Util::Platform.linux?
          'Linux'
        elsif Vagrant::Util::Platform.darwin?
          'Darwin'
        end
      end

      def archive_ext
        # https://github.com/docker/docker/blob/v1.11.0-rc1/CHANGELOG.md#1110-2016-04-12
        if @version == 'latest' || Gem::Version.new(@version) > Gem::Version.new('1.10.3')
          Vagrant::Util::Platform.windows? ? '.zip' : '.tgz'
        else
          binary_ext
        end
      end
    end
  end
end
