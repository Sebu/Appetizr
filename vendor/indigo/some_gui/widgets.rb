module Indigo::SomeGui

  module Widget
    include Create
    include ObserveAttr
    attr_accessor :controller
    attr_accessor :block
    
    def parse_block(&block)
      if block_given? 
        block.call @parent
      end
    end

    def show_all
      #parse_block(&@block)
      #self.children.each { |c| puts c } if self.children
    end
  end

    
  module Widgets
    include Indigo::SomeGui::Qt4Backend

    class Notification

      include Widget
      include ObserveAttr
      observe_attr :message

    
      def initialize(p, *args)
        
        begin
          require 'rbus'
          bus = RBus.session_bus
        rescue Exception
        end

        if bus then        
          @notifier = RBus.session_bus.get_object('org.freedesktop.Notifications', '/org/freedesktop/Notifications')
          Debug.log.debug "creating notification widget using d-bus"
          @send_mode = :dbus
        elsif File.exist?("/usr/bin/notify-send") then
          @send_mode = :send
          Debug.log.debug "creating notification widget using notify-send"
        else
          Debug.log.debug "no notification support found"          
        end      
      end

#      def parse_params(params)
#        super
#      end

      def notify(title,body,icon)
        case @send_mode
        when :dbus then
          @notifier.Notify(INDIGO_APP_NAME, 0, icon, title, body, [], {"x-canonical-append"=>RBus::Variant.new("true",'s')},-1)
        when :send then
          system("notify-send '#{title} ' '#{body}' -i #{icon}")
        end
      end


      def message=(args)
        title,body,icon = args
        notify(title,body, Res[icon])
      end
      
     
    end
  
  end

end
