
require 'rubygems'
require 'rbus'
notifier = RBus.session_bus.get_object('org.freedesktop.Notifications', '/org/freedesktop/Notifications')
notifier.Notify('adm', 0, 'notification-message-IM','scanSense', 'hi jo', [], {"x-canonical-append"=>RBus::Variant.new("true",'s')},-1)
notifier.Notify('adm', 0, 'notification-message-IM','scanSense', 'ho.',   [], {"x-canonical-append"=>RBus::Variant.new("true",'s')},-1)
