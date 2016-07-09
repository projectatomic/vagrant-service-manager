module VagrantPlugins
  module PluginLogger
    @debug = false

    def self.debug_mode?
      @debug
    end

    def self.logger
      @logger
    end

    def self.enable_debug_mode
      @debug = true
    end

    def self.logger=(logger)
      @logger = logger
    end

    def self.command
      (ARGV.drop(1) - ['--debug', '--script-readable']).join(' ')
    end

    def self.debug(message = nil)
      if debug_mode?
        message = command.to_s if message.nil?
        logger.debug "[ service-manager: #{message} ]"
      end
    end
  end
end
