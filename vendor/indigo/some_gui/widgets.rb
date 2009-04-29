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
        Debug.log.debug "creating notification"
        @notifier = RBus.session_bus.get_object('org.freedesktop.Notifications', '/org/freedesktop/Notifications')
      end

      def parse_params(params)
        super
      end

      def message=(value)
        text = value.to_s
        @notifier.Notify('adm', 0, 'info','rubyAdm status', text, [], {"x-canonical-append"=>RBus::Variant.new("true",'s')},-1)
      end

      def message
      end
        obsattr :message
    end
  
  end

end
