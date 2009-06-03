
# Another Signals + Slots Implementation for Ruby (c) Axel Plinge 2006

# in order to avoid eval(...) cascades, all signaling Objects
# have to 'include Signaling' in order to be able to 'emit'
module Signaling  
 
  # connect one of our signals to one someones slot i.e. method

  # syntax is:
  # connect(signal) {blob}
  # or
  # connect(signal, receiver, method, args)
  
  def on(signal, *args, &block)
    @connections ||= {}
    @connections[signal] = [] unless @connections[signal]
    data =  if block
              [block, nil, args] 
            elsif (args[0] and args[1]) # receiver and method
              [ args[0], args[1], args[2..-1] ] 
            else
              nil
            end
    return unless data
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
    return if @dirty
    return unless @connections
    connected_slots = @connections[name]
    return if !connected_slots or connected_slots.empty?
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
