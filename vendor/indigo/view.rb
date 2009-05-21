


module Indigo
  class View
    include EventHandleGenerator
    include SomeGui::Create
    include SomeGui::Render
    include SomeGui::Widgets
    
    attr_accessor :widgets
    attr_accessor :wiews
    
    
  end
end

