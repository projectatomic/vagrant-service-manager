require_relative '../../test_helper'
require 'vagrant/util/downloader'

# Tests through ADBOpenshiftBinaryHandler to BinaryHandler
module VagrantPlugins
  module ServiceManager
    describe ADBOpenshiftBinaryHandler do
      before do
        @machine = fake_machine
        @options = { type: :openshift, '--cli-version' => '1.2.0' }
        @archive_base_url = 'https://github.com/openshift/origin/releases/download/v1.2.0'
        @archive_file = 'openshift-origin-client-tools-v1.2.0-2e62fab-linux-64bit.tar.gz'
        @archive_file.sub!(/linux-64bit.tar.gz/, 'mac.zip') if Vagrant::Util::Platform.darwin?

        # set test path
        @plugin_test_path = "#{@machine.env.data_dir}/service-manager/test"
        ServiceManager.temp_dir = "#{@plugin_test_path}/temp"
        ServiceManager.bin_dir = "#{@plugin_test_path}/bin"

        @handler = ADBOpenshiftBinaryHandler.new(@machine, @machine.env, @options)
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
        @handler.path.must_equal "#{ServiceManager.bin_dir}/openshift/1.2.0/oc"
        expected_temp_bin_dir = "#{ServiceManager.temp_dir}/openshift"
        @handler.instance_variable_get('@temp_bin_dir').must_equal expected_temp_bin_dir
      end

      it 'should build download url' do
        expected_url = "#{@archive_base_url}/#{@archive_file}"

        @handler.send(:build_download_url)
        @handler.instance_variable_get('@url').must_equal expected_url
      end

      it 'should validate download url' do
        @options['--cli-version'] = '111.222.333'
        @handler = ADBDockerBinaryHandler.new(@machine, @machine.env, @options)
        @handler.build_download_url
        assert_raises(URLValidationError) { @handler.validate_url }
      end

      it 'should build archive path' do
        expected_path = "#{ServiceManager.temp_dir}/openshift/#{@archive_file}"

        @handler.build_download_url
        @handler.build_archive_path
        @handler.instance_variable_get('@archive_file_path').must_equal expected_path
      end

      it 'should ensure availability of binary and temp directories' do
        expected_bin_dir = "#{ServiceManager.bin_dir}/openshift"
        expected_temp_dir = "#{ServiceManager.temp_dir}/openshift"

        @handler.build_download_url
        @handler.build_archive_path
        @handler.ensure_binary_and_temp_directories

        assert_equal(File.directory?(expected_bin_dir), true)
        assert_equal(File.directory?(expected_temp_dir), true)
      end

      it 'should not download if archive file exists' do
        archive_file_dir = "#{ServiceManager.temp_dir}/openshift"
        FileUtils.mkdir_p(archive_file_dir) unless File.directory?(archive_file_dir)
        FileUtils.touch("#{archive_file_dir}/#{@archive_file}")

        @handler.build_download_url
        @handler.build_archive_path
        @handler.download_archive

        @handler.skip_download.must_equal true
      end

      it 'should prepare binary properly' do
        test_archive_path = "#{test_data_dir_path}/#{@archive_file}"

        @handler.build_download_url
        @handler.build_archive_path
        @handler.ensure_binary_and_temp_directories

        FileUtils.cp(test_archive_path, @handler.archive_file_path)

        @handler.prepare_binary
        @handler.binary_name.must_equal 'oc'
        @handler.file_regex.must_equal /oc$/
        if Vagrant::Util::Platform.darwin?
          @handler.archive_handler_class.must_equal VagrantPlugins::ServiceManager::ZipHandler
        else
          @handler.archive_handler_class.must_equal VagrantPlugins::ServiceManager::TarHandler
        end
        assert_equal(File.exist?(@handler.path), true)
      end
    end
  end
end
