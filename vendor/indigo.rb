


# extensions to Ruby libs
autoload :CommandPattern, 'command_pattern'
autoload :Signaling, 'signaling'
autoload :ObserveAttr, 'observe_attr'
autoload :YAML, 'yaml'

module Indigo
  def application(&block)
    app = ApplicationController.new(ARGV)
    app.instance_eval(&block)
    app.main_loop
  end

  # core
  autoload :SomeGui, 'indigo/some_gui'
  autoload :Dispatcher, 'indigo/dispatcher'
  autoload :Controller, 'indigo/controller'
  autoload :TranslationHelper, 'indigo/helpers/translation_helper'
  # model classes
  autoload :ActiveNode, 'indigo/models/active_node'
  autoload :ObjectListStore, 'indigo/models/object_list_store'  
end


#bootup
require 'vendor/indigo/boot'

