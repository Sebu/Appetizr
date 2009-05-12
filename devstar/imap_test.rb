




require 'net/imap'
require 'rubygems'
require 'rbus'
require 'hpricot'
autoload :YAML, 'yaml'

CONFIG = {"username"=>"", }
config_filename = "#{ENV["HOME"]}/.indigo/imapster.yml"
CONFIG.merge!(YAML.load_file(config_filename)) if File.exist?(config_filename)

convs = {}
purple = RBus.session_bus.get_object("im.pidgin.purple.PurpleService", "/im/pidgin/purple/PurpleObject")


purple.connect!(:ConversationCreated) do |conv|
  convs[conv] = {:text=>"",:sender=>nil, :links=>false}
end

purple.connect!(:WroteImMsg) do |account, who, message, conv, flags|
  #get alias
  alias_name = purple.PurpleBuddyGetAlias(purple.PurpleFindBuddy(account, who))
  who = alias_name if alias_name != ""
  convs[conv][:sender] = who
  who = "me" if flags == 1
  doc =  Hpricot(message)
  message = (doc/"body").inner_html if flags == 2
  convs[conv][:links] = true unless (doc/"a").empty?
  convs[conv][:text] +="<font color=gray>#{Time.now.strftime("%H:%M")}</font> <b>#{who}:</b> #{message}<br>"
end


purple.connect!(:DeletingConversation) do |conv,type|
  sender = convs[conv][:sender]
  message = convs[conv][:text]
  links = convs[conv][:links]
  convs.delete(conv)
  if links
    imap = Net::IMAP.new('imap.gmail.com', '993', true)
    imap.login(CONFIG["username"], CONFIG["password"])
    imap.append('talks',  "From: #{sender}\r\nTo: me\r\nSubject: talk with #{sender}\r\nContent-Type:text/html\r\n\r\n#{message}")
    puts "sending"
    imap.logout()
    imap.disconnect()
  end
end

puts "prep done"

RBus.mainloop

