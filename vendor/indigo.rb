


# nice extensions (set in initializer ext_mod = [Qt,Gl,...])
autoload :Gl, 'gl'
autoload :Qt, 'Qt'



# extensions to Ruby libs
autoload :CommandPattern, 'command_pattern'
autoload :Signaling, 'signaling'
autoload :ObserveAttr, 'observe_attr'

class Debug
  class << self
    attr_accessor :log
  end
  @log = ActiveSupport::BufferedLogger.new STDOUT
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

