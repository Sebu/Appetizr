module Indigo::SomeGui

  module Widget
    include Create
    include Signaling
    include ObserveAttr
    attr_accessor :controller
    
    def parse_block(&block)
      if block_given? 
        block.call @parent
      end
      show_all
    end

    def show_all
    end
  end

    
  module Widgets
    include Indigo::SomeGui::Qt4Backend

    class Notification
      require 'rbus'
      include Widget
      include ObserveAttr
    
      def initialize(p, *args)
        bus = RBus.session_bus
        if bus then        
          @notifier = RBus.session_bus.get_object('org.freedesktop.Notifications', '/org/freedesktop/Notifications')
          Debug.log.debug "creating notification widget using dbus"
          @send_mode = :dbus
        elsif File.exist?("/usr/bin/notify-send") then
          @send_mode = :send
          Debug.log.debug "creating notification widget using notify-send"
        else
          Debug.log.debug "no notifications support found"          
        end      
      end

      def parse_params(params)
        super
      end

      def message=(args)
        title,body,icon = args
        #  "important" "undo" "redo" "info/hint" "error" "unlocked" "locked"
        app_internal_icon ="#{APP_DIR}/resources/images/#{icon}.svg"
        if File.exist? app_internal_icon then 
          icon = app_internal_icon
        end
        notify(title,body,icon)
      end
      
      def notify(title,body,icon)
        case @send_mode
        when :dbus then
          @notifier.Notify(INDIGO_APP_NAME, 0, icon, title, body, [], {"x-canonical-append"=>RBus::Variant.new("true",'s')},-1)
        when :send then
          puts title, body, icon
          system("notify-send '#{title}' '#{body}' -i #{icon}")
        end
      end


      def message
      end
      obsattr :message
      
    end
  
  end

end
