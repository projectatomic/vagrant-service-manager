require_relative '../test_helper'

module VagrantPlugins
  module ServiceManager
    describe 'Archive Handlers' do
      before do
        @machine = fake_machine

        # set test path
        @plugin_test_path = "#{@machine.env.data_dir}/service-manager/test"
      end

      after do
        FileUtils.rmtree(@plugin_test_path) if File.directory? @plugin_test_path
      end

      describe TarHandler do
        it "should unpack '.tgz' archive properly" do
          test_archive_path = "#{test_data_dir_path}/docker-1.11.0.tgz"
          dest_binary_path = @plugin_test_path + '/docker-1.11.0'
          regex = %r{\/docker$}

          TarHandler.new(test_archive_path, dest_binary_path, regex).unpack
          assert_equal(File.exist?(dest_binary_path), true)
        end

        it "should unpack '.tar.gz' archive properly" do
          test_archive_path = "#{test_data_dir_path}/docker-1.10.0.tar.gz"
          dest_binary_path = @plugin_test_path + '/docker-1.10.0'
          regex = %r{\/docker$}

          TarHandler.new(test_archive_path, dest_binary_path, regex).unpack
          assert_equal(File.exist?(dest_binary_path), true)
        end
      end

      describe ZipHandler do
        it "should unpack '.zip' archive properly" do
          test_archive_path = "#{test_data_dir_path}/docker-1.9.1.zip"
          dest_binary_path = @plugin_test_path + '/docker-1.9.1'
          regex = %r{\/docker.exe$}

          ZipHandler.new(test_archive_path, dest_binary_path, regex).unpack
          assert_equal(File.exist?(dest_binary_path), true)
        end
      end
    end
  end
end
