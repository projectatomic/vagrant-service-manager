require_relative '../../test_helper'
require 'vagrant/util/downloader'

# Tests through ADBKubernetesBinaryHandler to BinaryHandler
module VagrantPlugins
  module ServiceManager
    describe ADBKubernetesBinaryHandler do
      before do
        @machine = fake_machine
        @options = { type: :kubernetes, '--cli-version' => '1.2.0' } # 1.2.0 is available in CDK/ADB VM
        @base_download_url = 'https://storage.googleapis.com/kubernetes-release/release'
        # set test path
        @plugin_test_path = "#{@machine.env.data_dir}/service-manager/test"
        ServiceManager.temp_dir = "#{@plugin_test_path}/temp"
        ServiceManager.bin_dir = "#{@plugin_test_path}/bin"

        @handler = ADBKubernetesBinaryHandler.new(@machine, @machine.env, @options)
      end

      after do
        FileUtils.rmtree(@plugin_test_path) if File.directory? @plugin_test_path
      end

      it 'should set defaults values properly' do
        @handler.instance_variable_get('@machine').must_equal @machine
        @handler.url.must_equal ''
        @handler.binary_exists.must_equal true
        @handler.skip_download.must_equal false
        @handler.archive_file_path.must_equal ''
        @handler.type.must_equal @options[:type]
        @handler.version.must_equal @options['--cli-version']
        @handler.path.must_equal "#{ServiceManager.bin_dir}/kubernetes/1.2.0/kubectl"
        expected_temp_bin_dir = "#{ServiceManager.temp_dir}/kubernetes"
        @handler.instance_variable_get('@temp_bin_dir').must_equal expected_temp_bin_dir
      end

      it 'should build download url' do
        expected_url = @base_download_url + '/v1.2.0/bin/linux/amd64/kubectl'
        expected_url.sub!(/linux/, 'darwin') if Vagrant::Util::Platform.darwin?

        @handler.send(:build_download_url)
        @handler.instance_variable_get('@url').must_equal expected_url
      end

      it 'should validate download url' do
        @handler.build_download_url
        @handler.validate_url.must_equal true
      end

      it 'should raise error with invalid --cli-version' do
        @options['--cli-version'] = '111.222.333'
        @handler = ADBKubernetesBinaryHandler.new(@machine, @machine.env, @options)
        @handler.build_download_url
        assert_raises(URLValidationError) { @handler.validate_url }
      end

      it 'should build archive path' do
        expected_path = "#{ServiceManager.temp_dir}/kubernetes/kubectl"
        @handler.build_download_url
        @handler.build_archive_path
        @handler.instance_variable_get('@archive_file_path').must_equal expected_path
      end

      it 'should ensure availability of binary and temp directories' do
        expected_bin_dir = "#{ServiceManager.bin_dir}/kubernetes"
        expected_temp_dir = "#{ServiceManager.temp_dir}/kubernetes"

        @handler.build_download_url
        @handler.build_archive_path
        @handler.ensure_binary_and_temp_directories

        assert_equal(File.directory?(expected_bin_dir), true)
        assert_equal(File.directory?(expected_temp_dir), true)
      end

      it 'should not download if archive file exists' do
        archive_file_dir = "#{ServiceManager.temp_dir}/kubernetes"
        FileUtils.mkdir_p(archive_file_dir) unless File.directory?(archive_file_dir)
        FileUtils.touch("#{archive_file_dir}/kubectl")

        @handler.build_download_url
        @handler.build_archive_path
        @handler.download_archive

        @handler.skip_download.must_equal true
      end

      it 'should prepare binary properly' do
        test_archive_path = "#{test_data_dir_path}/kubectl"

        @handler.build_download_url
        @handler.build_archive_path
        @handler.ensure_binary_and_temp_directories

        FileUtils.cp(test_archive_path, @handler.archive_file_path)

        @handler.prepare_binary
        @handler.binary_name.must_equal 'kubectl'
        assert_equal(File.exist?(@handler.path), true)
      end
    end
  end
end
