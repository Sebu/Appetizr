

module Indigo
  module EventHandleGenerator

    def link(signal, action, *args)
      connect(signal, self, action, *args)
    end

    def enter(action, *args)
      link(:enter, action, *args)
    end
 
    def click(action, *args)
      link(:click, action, *args)
    end
  
  end
end
