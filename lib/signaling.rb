
# Another Signals + Slots Implementation for Ruby (c) Axel Plinge 2006

# in order to avoid eval(...) cascades, all signaling Objects
# have to 'include Signaling' in order to be able to 'emit'
module Signaling  
 
  # connect one of our signals to one someones slot i.e. method

  # syntax is:
  # on(signal) { ... block ... }
  # or
  # on(signal, receiver, method, args)


  attr_accessor :signal_mappings
      
  def signal_mappings
    @signal_mappings ||= {}
  end

  # gtk shortcut      
  def on(signal, *args, &block)
    connect(signal, *([@controller]+args), &block)
  end    
      
  def connect(signal, *args, &block)
    data =  if block
              [block, nil, args] 
            elsif (args[0] and args[1]) # receiver and method
              [ args[0], args[1], args[2..-1] ] 
            else
              nil
            end
    return unless data

    mapping = self.signal_mappings[signal]
    if mapping
      connect_via_gtk(mapping, data, &block)     
    else
      connect_via_ruby(signal, data)
    end
  end

  def connect_via_gtk(signal, data, &block)
    if block_given?
      self.signal_connect(signal, &block)           
    elsif data[1].is_a?(String)
      self.signal_connect(signal) { data[0].visit(data[1], *data[2]) }
    else 
      self.signal_connect(signal) { data[0].send(data[1], *data[2]) } 
    end   
  end
  
  def connect_via_ruby(signal, data)
    @connections ||= {}
    @connections[signal] = [] unless @connections[signal]
    @connections[signal].push data
  end
  
  def disconnect(signal, *args, &pr)
		return unless @connections
    data = if pr then [pr, nil, args] else [ args[0], args[1], args[2..-1] ] end
		@connections[signal].delete(data)
	end

  
  # emit :signal name => call associated method with args or default value
  def emit(name,*args, &pr)
    @dirty ||= false
    @connections ||= nil
    return false if @dirty
    return nil unless @connections
    connected_slots = @connections[name]
    return nil if !connected_slots or connected_slots.empty?
    @dirty = true
    connected_slots.each do |obj, method, more|
		  if method == nil
			  obj.call(*(args+more), &pr)
		  else
			  obj.send(method, *(args+more), &pr)
		  end
    end
    @dirty = false
    return true
  end
end
