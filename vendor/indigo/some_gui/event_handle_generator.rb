

module Indigo
  module SomeGui
    module EventHandleGenerator
      
      # TODO: autogenerate
      def enter(action=nil, *args, &block)
        gen_connection(:enter, action, *args, &block)
      end
   
      def click(action=nil, *args, &block)
        gen_connection(:click, action, *args, &block)
      end


      def gen_connection(signal, action, *args, &block)
        if block_given?
          on(signal, @controller, *args, &block)
        elsif action.is_a?(String)
          on(signal, @controller, *args) { @controller.redirect_to(action, *args) }
        else
          on(signal, @controller, action, *args)
        end
      end
    
    end
  end
end
