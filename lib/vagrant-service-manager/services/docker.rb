module Vagrant
  module ServiceManager
    SUPPORTED_BOXES = ['adb', 'cdk']

    module Service
      class Docker
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @ui = env[:ui]
        end

        def call(env)
          if SUPPORTED_BOXES.include? @machine.guest.capability(:flavor)
            command = "sudo rm /etc/docker/ca.pem && sudo systemctl restart docker"
            @machine.communicate.execute(command) do |type, data|
              if type == :stderr
                @ui.error(data)
                exit 126
              end
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
