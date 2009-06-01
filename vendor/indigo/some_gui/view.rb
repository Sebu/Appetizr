


module Indigo
  module SomeGui
  
    class View
      include Render
      
      
  #    attr_accessor :widgets
  #    attr_accessor :wiews

      def self.load_file(filename)
        content = ''
        File.open(filename, 'r') { |f| content = f.read }
        Debug.log.debug "  \e[1;36mloading render block\e[0m #{filename}"
        content
      end  
     
      def self.widgets
        @widgets ||= {}
      end
      
      def self.[](name)
        @views ||= {}
        @views[name] ||= load_file(name)
      end
      
    end 
    
    
  end
end

