

INDIGO_APP_NAME = APP_DIR.split("/")[-1]
CONFIG = {}


# BOOT
module Indigo
  class Boot
    
   def self.run!
      init_framework
      init_paths
      init_config
      init_logger
      init_locale
      init_plugins
    end
    
    
    def self.init_framework
      require 'rubygems'
      require 'activesupport'
      require 'indigo'
    end
    
    def self.init_paths
      # add paths to lib and ActiveSupport::Dependecies
      extra_paths = ['', '/app','/app/controllers', '/app/models', '/app/helpers']
      extra_paths.each { |path| ActiveSupport::Dependencies.load_paths << APP_DIR + path }
      $:.unshift APP_DIR + '/vendor/indigo'
      $:.unshift APP_DIR + '/resources'
    end
    

    def self.init_config
      config_files = ["#{APP_DIR}/config/config_defaults.yml",   # defaults
                      "#{ENV['HOME']}/.indigo/#{INDIGO_APP_NAME}/config.yml",   # user
                      "#{APP_DIR}/config/config.yml"]            # readonly
      config_files.each do |config_filename|
        if File.exist?(config_filename) then
          Debug.log.debug "  \e[1;36mLoading config\e[0m #{config_filename}"
          config_file = YAML.load_file(config_filename)
          CONFIG.merge!(config_file["all"])
          CONFIG.merge!(config_file[INDIGO_ENV])
        end
      end
    end

        
    def self.init_logger
      ActiveRecord::Base.logger = Debug.log
    end
    

    def self.init_plugins
      require 'indigo/some_gui/platform/gtk_backend' # read from config or default
    end

        
    def self.init_locale
      I18n.load_path = Dir[File.join(APP_DIR, 'config', 'locales', '*.{rb,yml}')]
      I18n.default_locale = :de 
      I18n.locale = CONFIG["locale"]
    end

  end
end

Indigo::Boot.run!

