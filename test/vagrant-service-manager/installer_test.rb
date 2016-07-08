require_relative '../test_helper'

module VagrantPlugins
  module ServiceManager
    describe Installer do
      before do
        @machine = fake_machine

        # set test path
        @plugin_test_path = "#{@machine.env.data_dir}/service-manager/test"
        ServiceManager.bin_dir = "#{@plugin_test_path}/bin"
        ServiceManager.temp_dir = "#{@plugin_test_path}/temp"
      end

      after do
        FileUtils.rmtree(@plugin_test_path) if File.directory? @plugin_test_path
      end

      describe 'Docker' do
        before do
          @type = :docker
          @options = { box_version: 'adb', '--cli-version' => '1.11.0' }
          @installer = Installer.new(@type, @machine, @machine.env, @options)
        end

        it 'should set default values properly' do
          @installer.instance_variable_get('@type').must_equal @type
          @installer.instance_variable_get('@machine').must_equal @machine
          @installer.instance_variable_get('@env').must_equal @machine.env
          @installer.instance_variable_get('@box_version').must_equal 'adb'
        end

        it 'should build handler class dynamically' do
          @installer.handler_class.must_equal ADBDockerBinaryHandler.to_s
        end

        it 'should skip installing if binary path exists' do
          # create mock docker binary
          bin_folder_path = "#{ServiceManager.bin_dir}/docker/#{@options['--cli-version']}"
          FileUtils.mkdir_p(bin_folder_path)
          FileUtils.touch("#{bin_folder_path}/docker")

          @installer.instance_variable_get('@binary_handler').binary_exists.must_equal true
        end
      end

      describe 'OpenShift' do
        before do
          @type = :openshift
          @options = { box_version: 'adb', '--cli-version' => '1.2.0' }
          @installer = Installer.new(@type, @machine, @machine.env, @options)
        end

        it 'should set default values properly' do
          @installer.instance_variable_get('@type').must_equal @type
          @installer.instance_variable_get('@machine').must_equal @machine
          @installer.instance_variable_get('@env').must_equal @machine.env
          @installer.instance_variable_get('@box_version').must_equal 'adb'
        end

        it 'should build handler class dynamically' do
          @installer.handler_class.must_equal ADBOpenshiftBinaryHandler.to_s
        end

        it 'should skip installing if binary path exists' do
          # create mock docker binary
          bin_folder_path = "#{ServiceManager.bin_dir}/openshift/#{@options['--cli-version']}"
          FileUtils.mkdir_p(bin_folder_path)
          FileUtils.touch("#{bin_folder_path}/oc")

          @installer.instance_variable_get('@binary_handler').binary_exists.must_equal true
        end
      end
    end
  end
end
