
require 'rubygems'
require 'rbus'

purple = RBus.session_bus.get_object("im.pidgin.purple.PurpleService", "/im/pidgin/purple/PurpleObject")
purple.connect!(:ReceivedImMsg) do |account, sender, message, conversation, flags|
  p purple.PurpleAccountGetUsername(account)
  puts account, sender, message, conversation
end

puts "prep done"

RBus.mainloop

