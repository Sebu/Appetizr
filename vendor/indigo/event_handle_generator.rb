

module Indigo
  module EventHandleGenerator

    def enter(action, *args)
      connect(:enter, self, action, *args)
    end
 
    def click(action, *args)
      connect(:click, self, action, *args)
    end
  
  end
end
