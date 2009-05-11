
require 'rubygems'
require 'rbus'

purple = RBus.session_bus.get_object("im.pidgin.purple.PurpleService", "/im/pidgin/purple/PurpleObject")

purple.connect!(:ReceivedImMsg) do |account, sender, message, conversation, flags|
  p purple.PurpleAccountGetUsername(account)
  puts account, sender, message, conversation
end

accounts = purple.PurpleAccountsGetAllActive.each do |account|
  p purple.PurpleAccountGetUsername(account)
  p purple.PurpleAccountGetProtocolName(account)
end

conv = purple.PurpleConversationNew(1, accounts[2], "Sebu@jabber.ccc.de/Home")
p conv
im = purple.PurpleConvIm(conv)
p im
purple.PurpleConvImSend(im, "test123")


#puts "prep done"

#RBus.mainloop

