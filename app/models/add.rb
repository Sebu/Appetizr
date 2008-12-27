
require 'active_node'

class Add
  include Indigo::ActiveNode
  include Indigo::ObserveAttr
  obs_attr :rotation
end
