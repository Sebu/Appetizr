
require 'dbus'


bus  = DBus::SessionBus.instance
service = bus.service('org.freedesktop.Notifications')
proxy = service.object('/org/freedesktop/Notifications')
proxy.introspect
notifier = proxy['org.freedesktop.Notifications']
notifier.Notify('adm', 0, 'notification-message-IM','scanSense', 'hi jo', [], {"x-canonical-append"=>['s',"true"]},-1)
notifier.Notify('adm', 0, 'notification-message-IM','scanSense', 'hi sdsdjo', [], {"x-canonical-append"=>['s',"true"]},-1)

