
#TODO: make everything more clean


# add /app and co. to path
$:.unshift APP_DIR + '/resources'
$:.unshift APP_DIR + '/app'
$:.unshift APP_DIR + '/app/controllers'
$:.unshift APP_DIR + '/app/models'
$:.unshift APP_DIR + '/app/views'
$:.unshift APP_DIR + '/app/helpers'

#get environment
require 'config/environment'

require 'rubygems'
require 'active_support'
require 'indigo'

#get config/config.yml
require 'yaml'
config_file = YAML.load_file("#{APP_DIR}/resources/config/config.yml")
Config  = config_file["all"]
Config.merge!(config_file[INDIGO_ENV])


module Indigo
  class Boot
    include Application
    
    # startup the app    
    def self.run!

      I18n.load_path = Dir[File.join(APP_DIR, 'resources', 'config', 'locales', '*.{rb,yml}')]
      I18n.locale = Config[:locale]


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


