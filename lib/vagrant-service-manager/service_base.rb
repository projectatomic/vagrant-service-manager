module VagrantPlugins
  module ServiceManager
    class ServiceBase
      def initialize(machine, env)
        @machine = machine
        @env = env
        @ui = env.respond_to?('ui') ? env.ui : env[:ui]
        @services = @machine.config.servicemanager.services.split(',').map(&:strip)
        home_path = env.respond_to?('home_path') ? env.home_path : env[:home_path]
        @plugin_dir = File.join(home_path, 'data', 'service-manager')
      end

      def service_start_allowed?
        true # always start service by default
      end

      def cdk?
        @machine.guest.capability(:os_variant) == 'cdk'
      end

      def proxy_cmd_options
        options = ''

        return options unless http_proxy_settings_valid?

        PROXY_CONFIG.each do |key|
          options += "#{key.to_s.upcase}='#{@machine.config.servicemanager.send(key)}' "
        end

        options.chop
      end

      def http_proxy_settings_valid?
        proxy = @machine.config.servicemanager.send('http_proxy')
        user = @machine.config.servicemanager.send('http_proxy_user')
        password = @machine.config.servicemanager.send('http_proxy_password')

        if proxy && user.nil? && password.nil? || (proxy && user && password)
          PluginLogger.debug('Detected proxy settings. Going to apply them to service commands.')
          values = "Proxy URL : #{proxy}"
          values += ", User : #{user}, Password: *** " unless user.nil?
          PluginLogger.debug(values)
          return true
        end

        warn_proxy_settings_missing(proxy, user, password)
        false
      end

      def warn_proxy_settings_missing(proxy, user, password)
        # Check if user try to set proxy
        return if proxy.nil? && user.nil? && password.nil?
        message = 'Proxy URL is missing' if proxy.nil?
        message = 'Either user or password is missing.' if proxy && user.nil? || proxy && password.nil?
        @ui.warn message
      end
    end
  end
end
