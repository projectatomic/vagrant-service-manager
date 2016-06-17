module VagrantPlugins
  module ServiceManager
    VERSION_CMD = {
      docker: "docker version --format '{{.Server.Version}}'",
      openshift: "oc version | grep 'oc' | grep -oE '[0-9.]+'"
    }

    class ADBInstaller < Installer
      # Refer https://docs.docker.com/v1.10/engine/installation/binaries
      DOCKER_BINARY_BASE_URL = 'https://get.docker.com/builds'

      OC_BINARY_BASE_URL = 'https://github.com/openshift/origin/releases'
      OC_FILE_PREFIX = 'openshift-origin-client-tools'

      def initialize(type, machine, env, options)
        super(type, machine, env, options)
      end

      def build_download_url
        arch = @machine.env.host.capability(:os_arch)
        @url = "#{DOCKER_BINARY_BASE_URL}/#{docker_os_type}/#{arch}/docker-#{@version}#{docker_ext}"
      end

      def ensure_binary_and_temp_directories
        bin_dir = File.dirname(@path)
        FileUtils.mkdir_p(bin_dir) unless File.directory?(bin_dir)
        Dir.mkdir(@temp_bin_dir) unless File.directory?(@temp_bin_dir)
      end

      def download_and_prepare_binary
        archive_file_name = File.basename(@url)
        Vagrant::Util::Downloader.new(@url, "#{@temp_bin_dir}/#{archive_file_name}").download!
        archive_dir_name = archive_file_name.gsub('.tgz|.tar.gz|.zip', '')
        puts "archive_file_name: #{archive_file_name}"
        puts "archive_dir_name: #{archive_dir_name}"
        puts "url: #{@url}, path : #{@path}"
        # Steps to download binary
        # open zip/tar file and read particular binary and copy it and then exit
        # FileUtils.cp("#{@temp_bin_dir}/#{archive_dir_name}/#{@binary_name}", @path)
      end

      def docker_os_type
        if OS.windows?
          'Windows'
        elsif OS.unix?
          'Linux'
        elsif OS.mac?
          'Darwin'
        end
      end

      def docker_ext
        OS.windows? ? '.zip' : '.tgz'
      end

      def openshift_binary_download_url
        arch = @machine.env.host.capability(:os_arch)
        download_base_path = "#{OC_BINARY_BASE_URL}/download/v#{@version}/"
        file = "#{OC_FILE_PREFIX}-v#{@version}-#{version_sha}-#{ext}"
        download_base_path + file
      end

      def version_sha
        require 'net/http'

        tag_url =  "#{OC_BINARY_BASE_URL}/tag/v#{@version}"
        data = Net::HTTP.get(URI(tag_url))
        tokens = data.match("-v#{@version}-(.*)-#{ext}").captures
        tokens.first unless tokens.empty?
      end

      def oc_os_type
        if OS.windows?
          'windows'
        elsif OS.linux?
          'linux'
        elsif OS.mac?
          'mac'
        end
      end

      def arch
        arch = @machine.env.host.capability(:os_arch)
        arch == 'x86_64' ? '64' : '32'
      end

      def ext
        oc_os_type + (oc_os_type == 'linux' ? "-#{arch}bit.tar.gz" : ".zip")
      end
    end
  end
end
