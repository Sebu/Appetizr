



# setup path and some environment variables
#Dir.chdir "#{File.dirname(__FILE__)}/../.."
APP_DIR = Dir.pwd
INDIGO_APP_NAME = APP_DIR.split("/")[-1].to_s.upcase
INDIGO_ENV = ENV["#{INDIGO_APP_NAME}_ENV"] ||= "production"
CONFIG = {}


# BOOT
module Indigo
  class Boot
    
   def self.run!
      init_paths
      init_framework
      init_dependencies
      init_config
      init_logger
      init_locale
      init_plugins
    end
    
    
    def self.init_framework
      # extend core  
      require 'rubygems'
      require 'activerecord'
      require 'activesupport'
      require 'indigo/core_ext'
    end

    # add paths to lib and ActiveSupport::Dependecies
    def self.init_paths
      extra_paths = ['/vendor','/vendor/indigo', '/resources']
      extra_paths.each { |path| $:.unshift << APP_DIR + path }
    end
    def self.init_dependencies
      extra_paths = ['', '/app','/app/controllers', '/app/models', '/app/helpers']
      extra_paths.each { |path| ActiveSupport::Dependencies.load_paths << APP_DIR + path }
    end


    def self.init_config
      config_files = ["#{APP_DIR}/config/config_defaults.yml",   # defaults
                      "#{ENV['HOME']}/.indigo/#{INDIGO_APP_NAME}/config.yml",   # user
                      "#{APP_DIR}/config/config.yml"]            # readonly
      config_files.each do |config_filename|
        if File.exist?(config_filename) then
          puts "  \e[1;36mLoading config\e[0m #{config_filename}"
          config_file = YAML.load_file(config_filename)
          CONFIG.merge!(config_file["all"])
          CONFIG.merge!(config_file[INDIGO_ENV])
        end
      end
    end

        
    def self.init_logger
      Kernel.class_eval %{
        class Debug
          class << self
            attr_accessor :log
          end
          @log = ActiveSupport::BufferedLogger.new STDOUT 
        end
      }
      ActiveRecord::Base.logger = Debug.log
    end
    

    def self.init_plugins
      require 'indigo/some_gui/gtk_backend' # read from config or default
    end

        
    def self.init_locale
      I18n.load_path = Dir[File.join(APP_DIR, 'resources', 'locales', '*.{rb,yml}')]
      I18n.default_locale = :de 
      I18n.locale = CONFIG["locale"]
    end

  end
end

Indigo::Boot.run!

