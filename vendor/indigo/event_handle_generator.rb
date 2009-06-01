

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
        connect(signal, self, *args, &block)
      elsif action.is_a?(String)
        connect(signal, self, *args) { self.redirect_to(action, *args) }
      else
        connect(signal, self, action, *args)
      end
    end
  
  end
end
