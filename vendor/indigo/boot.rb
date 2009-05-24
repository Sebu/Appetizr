
#TODO:  make everything more clean
#       and move to a initializer??
require 'rubygems'
require 'activesupport'

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

# TODO: set app dir (should we do this in initializer or config file?)
INDIGO_APP_NAME = APP_DIR.split("/")[-1]

# load CONFIG
autoload :YAML, 'yaml'
CONFIG = {}
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


# BOOT
module Indigo
  class Boot
    include Application
    
    # startup the app    
    # should be more like
    # init_framework 
    # logger
    # init_plugins
    # inti...
    # NOT App.run (move to something like commands/start)
    def self.run!
      I18n.load_path = Dir[File.join(APP_DIR, 'config', 'locales', '*.{rb,yml}')]
      I18n.locale = CONFIG["locale"]
    end
  end
end

Indigo::Boot.run!

