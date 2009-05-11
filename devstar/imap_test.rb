




require 'net/imap'
require 'rubygems'
require 'rbus'
require 'hpricot'


username = ''
password = ''
purple = RBus.session_bus.get_object("im.pidgin.purple.PurpleService", "/im/pidgin/purple/PurpleObject")


convs = {}

purple.connect!(:ConversationCreated) do |conv|
  convs[conv] = {:text=>"",:sender=>nil, :links=>false}
end

purple.connect!(:WroteImMsg) do |account, who, message, conv, flags|
  alias_name = purple.PurpleBuddyGetAlias(purple.PurpleFindBuddy(account, who))
  who = alias_name if alias_name != ""
  convs[conv][:sender] = who
  who = "me" if flags == 1
  doc =  Hpricot(message)
  message = (doc/"body").inner_html if flags == 2
  convs[conv][:links] = true unless (doc/"a").empty?
  convs[conv][:text] +="<font color=gray>#{Time.now.strftime("%H:%M")}</font> <b>#{who}:</b> #{message}<br>"
  #puts convs[conv][:text]
end


purple.connect!(:DeletingConversation) do |conv,type|
  sender = convs[conv][:sender]
  message = convs[conv][:text]
  links = convs[conv][:links]
  imap = Net::IMAP.new('imap.gmail.com', '993', true)
  imap.login(username, password)
  if links
    imap.append('talks',  "From: #{sender}\r\nTo: me\r\nSubject: talk with #{sender}\r\nContent-Type:text/html\r\n\r\n#{message}")
    puts "sending"
  end
  convs.delete(conv)
  imap.logout()
  imap.disconnect()
end

puts "prep done"

RBus.mainloop

