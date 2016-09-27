require_relative '../test_helper'

module VagrantPlugins
  module ServiceManager
    describe Installer do
      before do
        @machine = fake_machine
        @ui = FakeUI.new
        @machine.env.stubs(:ui).returns(@ui)

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
          @options = { type: :docker, box_version: 'adb', '--cli-version' => '1.11.0' }
          @installer = Installer.new(@machine, @machine.env, @options)
        end

        it 'should set default values properly' do
          @installer.instance_variable_get('@type').must_equal @options[:type]
          @installer.instance_variable_get('@machine').must_equal @machine
          @installer.instance_variable_get('@env').must_equal @machine.env
          @installer.instance_variable_get('@options').must_equal(@options)
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
          @options = { type: :openshift, box_version: 'adb', '--cli-version' => '1.2.0' }
          @installer = Installer.new(@machine, @machine.env, @options)
        end

        it 'should set default values properly' do
          @installer.instance_variable_get('@type').must_equal @options[:type]
          @installer.instance_variable_get('@machine').must_equal @machine
          @installer.instance_variable_get('@env').must_equal @machine.env
          @installer.instance_variable_get('@options').must_equal(@options)
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

      describe 'Kubernetes' do
        before do
          @options = { type: :kubernetes, box_version: 'adb' }
          @installer = Installer.new(@machine, @machine.env, @options)
        end

        it 'should set default values properly' do
          @installer.instance_variable_get('@type').must_equal @options[:type]
          @installer.instance_variable_get('@machine').must_equal @machine
          @installer.instance_variable_get('@env').must_equal @machine.env
          @installer.instance_variable_get('@options').must_equal(@options)
        end

        it 'should build handler class dynamically' do
          @installer.handler_class.must_equal ADBKubernetesBinaryHandler.to_s
        end

        it 'should skip installing if binary path exists' do
          # create mock docker binary
          bin_folder_path = "#{ServiceManager.bin_dir}/kubernetes/#{@options['--cli-version']}"
          FileUtils.mkdir_p(bin_folder_path)
          FileUtils.touch("#{bin_folder_path}/kubectl")

          @installer.instance_variable_get('@binary_handler').binary_exists.must_equal true
        end
      end
    end
  end
end
