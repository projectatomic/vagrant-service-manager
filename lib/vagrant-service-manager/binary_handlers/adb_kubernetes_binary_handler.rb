module VagrantPlugins
  module ServiceManager
    class ADBKubernetesBinaryHandler < ADBBinaryHandler
      # http://richieescarez.github.io/kubernetes/v1.0/docs/getting-started-guides/aws/kubectl.html
      BINARY_BASE_URL = 'https://storage.googleapis.com/kubernetes-release/release'.freeze

      def initialize(machine, env, options)
        super(machine, env, options)
      end

      def build_download_url
        @url = "#{BINARY_BASE_URL}/v#{@version}/bin/#{os_type}/#{arch}/kubectl"
      end

      private

      def os_type
        if Vagrant::Util::Platform.windows?
          'windows'
        elsif Vagrant::Util::Platform.linux?
          'linux'
        elsif Vagrant::Util::Platform.darwin?
          'darwin'
        end
      end

      def arch
        'amd64' # only supported arch
      end
    end
  end
end
