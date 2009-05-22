


module Indigo
  class View
    include SomeGui::Render
    
#    attr_accessor :widgets
#    attr_accessor :wiews

    def self.load_file(filename)
      content = ''
      File.open(filename, 'r') { |f| content = f.read }
      Debug.log.debug "loading render block #{filename}"
      #Debug.log.debug content
      content
    end  
   
#    def initialize
#      @views = {}
#      @widgets = {}
#    end
    
    def self.widgets
      @@widgets ||= {}
    end
    
    def self.[](name)
      @@views ||= {}
      @@views[name] ||= load_file(name)
    end
    
  end
end

