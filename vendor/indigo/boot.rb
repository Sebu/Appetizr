
#TODO:  make everything more clean
#       and move to a initializer??
require 'rubygems'
require 'active_support'

# get environment
require APP_DIR + '/config/environment'

# add paths to lib and ActiveSupport::Dependecies
extra_paths = ['', '/app','/app/controllers', '/app/models', '/app/helpers']
extra_paths.each { |path| ActiveSupport::Dependencies.load_paths << APP_DIR + path }
$:.unshift APP_DIR + '/resources'
$:.unshift APP_DIR + '/app/views'
extra_paths.each { |path| $:.unshift(APP_DIR + path) }

# load framework
require 'indigo'

# load CONFIG
# TODO: change the whole process
require 'yaml'
config_file = YAML.load_file("#{APP_DIR}/config/config.yml")
CONFIG  = config_file["all"]
CONFIG.merge!(config_file[INDIGO_ENV])



# BOOT
module Indigo
  class Boot
    include Application
    
    # startup the app    
    def self.run!
      I18n.load_path = Dir[File.join(APP_DIR, 'config', 'locales', '*.{rb,yml}')]
      I18n.locale = CONFIG[:locale]

      #      Application::Base
      Base.log.debug "booting.." 
      #init stuff

      # the real app starting
      App.run

      Base.log.debug "..shutdown"
      #shutdown
    end

  end
end

Indigo::Boot.run!

