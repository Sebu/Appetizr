
require 'lib/observe_attr'

describe ObserveAttr do

  class ObserveAttrObject
    include ObserveAttr
    
    def bar
      @bar ||= 0
      @bar += 1
    end
  end
  
  before :each do
    @observe_attr = ObserveAttrObject.new
  end 

  it "" do
  end
  
end


