


# nice extensions (set in initializer ext_mod = [Qt,Gl,...])
autoload :Gl, 'gl'
autoload :Qt, 'Qt4'

# extensions to Ruby libs
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
    res
  end
end
  
module Indigo
  
  
  require 'indigo/core_ext'
  autoload :Application, 'indigo/application'
  autoload :SomeGui, 'indigo/some_gui'
  autoload :ActiveNode, 'indigo/active_node'
  autoload :EventHandleGenerator, 'indigo/event_handle_generator'
  autoload :Controller, 'indigo/controller'
  autoload :ARTableModel, 'indigo/ar_table_model'
  autoload :App,'app'
  


end

