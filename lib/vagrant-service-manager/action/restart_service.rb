module Vagrant
  module ServiceManager
    module Action
      class RestartService
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
          @providers = @machine.config.servicemanager.providers.split(',').map(&:chomp)
        end

        def execute_command(command, provider)
           @machine.communicate.execute(command) do |type, data|
            if type == :stderr
              @ui.error(data)
            else
              @ui.info("# Restarted #{provider} service.")
            end
          end
        end

        def call(env)
          @providers.each do |provider|
            command = "sudo systemctl restart #{provider}"
            command = "sudo rm /etc/docker/ca.pem && " + command if provider == 'docker'
            execute_command(command, provider)
          end

          @app.call(env)
        end
      end
    end
  end
end
