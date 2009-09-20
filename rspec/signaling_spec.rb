
require 'lib/signaling'

describe Signaling do

  class SignalingObject
    include Signaling
    
    def bar
      @bar ||= 0
      @bar += 1
    end
  end
  
  before :each do
    @signaling = SignalingObject.new
  end 

  it "should not be allowed to #connect nil objects" do
    @signaling.connect(:foo, nil, :bar).should == nil
  end  

  it "should return true after #connect(:foo, ,:bar) and #emit(:foo)" do
    @signaling.connect(:foo, @signaling, :bar)
    @signaling.emit(:foo).should == true
    @signaling.bar.should > 0
  end

  it "should return true after #on(:foo) and #emit(:foo)" do
    @signaling.on(:foo) do @signaling.bar end
    @signaling.emit(:foo).should == true
    @signaling.bar.should > 0
  end


  it "should not be allowed to #emit(:foo) after #disconnect(:foo)" do
    @signaling.connect(:foo, @signaling, :bar)
    @signaling.disconnect(:foo, @signaling, :bar)
    @signaling.emit(:foo).should == nil
  end
  
end


