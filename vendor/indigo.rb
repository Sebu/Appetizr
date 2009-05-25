

# extensions to Ruby libs
autoload :YAML, 'yaml'
autoload :CommandPattern, 'command_pattern'
autoload :Signaling, 'signaling'
autoload :ObserveAttr, 'observe_attr'

class Debug
  class << self
    attr_accessor :log
  end
  @log = ActiveSupport::BufferedLogger.new STDOUT #INDIGO_ENV =='development' ? STDOUT : "log/main.log"
end


# TODO: move into own module/file
#  "important" "undo" "redo" "info/hint" "error" "unlocked" "locked"
class Res
  def self.[](res)
    app_internal_res = "#{APP_DIR}/resources/images/#{res}.svg"
    res = app_internal_res if File.exist? app_internal_res
    app_internal_res = "#{APP_DIR}/resources/images/#{res}.png"
    res = app_internal_res if File.exist? app_internal_res
    res
  end
end
  
module Indigo
  
  # extend core  
  require 'indigo/core_ext'
  # core classes
  autoload :App,'app'
  autoload :Application, 'indigo/application'
  autoload :View, 'indigo/view'
  autoload :SomeGui, 'indigo/some_gui'
  autoload :EventHandleGenerator, 'indigo/event_handle_generator'
  autoload :Controller, 'indigo/controller'
  # model classes
  autoload :Printer, 'indigo/models/printer'
  autoload :ActiveNode, 'indigo/models/active_node'
  autoload :ObjectListStore, 'indigo/models/object_list_store'  


end

