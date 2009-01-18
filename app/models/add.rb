

class Add
  include Indigo::ActiveNode
  include ObserveAttr
  attr_accessor :rotation  
  obs_attr :rotation
end
