

module Indigo
  module EventHandleGenerator

    def enter(action=nil, *args)
      if block_given?
        connect(:enter, self, *args, &block)
      else
        connect(:enter, self, action, *args)
      end
    end
 
    def click(action=nil, *args, &block)
      if block_given?
        connect(:click, self, *args, &block)
      else
        connect(:click, self, action, *args)
      end
    end
  
  end
end
