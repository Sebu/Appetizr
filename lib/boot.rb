

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

#get config/config.yml
require 'yaml'
config_file = YAML.load_file("#{APP_DIR}/resources/config/config.yml")
CONFIG  = config_file["all"]
CONFIG.merge!(config_file[INDIGO_ENV])


# I18n stuff :D (use :en by default)
$:.unshift '/var/lib/gems/1.8/gems/activesupport-2.2.2/lib'
require 'active_support'
I18n.load_path = Dir[File.join(APP_DIR, 'resources', 'config', 'locales', '*.{rb,yml}')]
I18n.locale = :en


require 'app'
require 'application'


# hmm nice somehow
include Indigo 
include Application

module Indigo
  class Boot

    # startup the app    
    def self.run

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

Indigo::Boot.run


