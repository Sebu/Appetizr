

module Indigo
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
        on(signal, self, *args, &block)
      elsif action.is_a?(String)
        on(signal, self, *args) { self.redirect_to(action, *args) }
      else
        on(signal, self, action, *args)
      end
    end
  
  end
end
