
# Another Signals + Slots Implementation for Ruby (c) Axel Plinge 2006

# in order to avoid eval(...) cascades, all signaling Objects
# have to 'include Signaling' in order to be able to 'emit'
module Signaling  
 
  # connect one of our signals to one someones slot i.e. method

  # syntax is:
  # connect(signal) {blob}
  # or
  # connect(signal, receiver, method, args)
  
  def connect(signal, *args, &pr)
    @connections = Hash.new unless @connections
    @connections[signal] = [] unless @connections[signal]
    data = if pr then [pr, nil, args] else [ args[0], args[1], args[2..-1] ] end
    @connections[signal].push data
  end

  def disconnect(signal, *args)
		return unless @connections
		@connections[signal].delete(args)
	end

  
  # emit :signal name => call associated method with args or default value
  def emit(name,*args, &pr)
    @dirty ||= false  
    return if @dirty
    return if !@connections
    connected_slots = @connections[name]
    return if !connected_slots
    @dirty = true
    connected_slots.each do |obj, method, more|
		  if method == nil
			  obj.call(*(args+more), &pr)
		  else
			  obj.send(method, *(args+more), &pr)
		  end
    end
    @dirty = false
  end
end
