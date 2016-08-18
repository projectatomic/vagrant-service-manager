module VagrantPlugins
  module ServiceManager
    module Action
      class LogConfiguredServices
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
          @services = @machine.config.servicemanager.services.split(',').map(&:strip)
        end

        def call(env)
          @app.call(env)

          @services.each do |service|
            if !PluginUtil.service_running?(@machine, service)
              @ui.info I18n.t('servicemanager.actions.service_failure', service: service.capitalize)
            elsif PluginUtil.service_running?(@machine, service)
              @ui.info I18n.t('servicemanager.actions.service_success', service: service.capitalize)
            end
          end
        end
      end
    end
  end
end
