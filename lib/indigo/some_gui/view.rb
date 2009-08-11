


module Indigo
  module SomeGui

    class View
      include Render

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
        @views[name.to_s] ||= load_file(name.to_s)
      end
    end 
    
    
  end
end

