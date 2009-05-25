# common widget code


module Indigo
  module SomeGui
    module Widgets
    
      module Widget
        include ObserveAttr
        attr_accessor :controller
        attr_accessor :block
        

        def add_element(widget)
        end
        def respond
          self
        end    

        def show_all
          #parse_block(&@block)
          #self.children.each { |c| puts c } if self.children
        end
      end

      class Notifier < Gtk::StatusIcon

        class Balloon < Gtk::Window
          attr_accessor :title, :body, :icon, :eventbox
          
          def initialize(t,b,i)
            super(Gtk::Window::POPUP)
            @eventbox = Gtk::EventBox.new

            @title = Gtk::Label.new
            title.set_markup("<span size='15000'>#{t}</span>")  

            @body = Gtk::Label.new
            body.wrap = true
            body.set_markup(b)
            
            image = Gtk::Image.new(i)

            vbox = Gtk::VBox.new(false,0)
            vbox.pack_start(title, false, false, 0)
            vbox.pack_start(body, false, false, 0)


            hbox = Gtk::HBox.new(false,0)
            hbox.pack_start(image, false, false, 0)
            hbox.pack_start(vbox, false, false, 0)


            eventbox.set_events(Gdk::Event::BUTTON_PRESS_MASK)
            eventbox.add(hbox)   

            add(eventbox)
            set_default_size(330,30)
            show_all
          end
          
        end

        def initialize
          @balloons = []		
          super
        end

        def align_balloons
          a,rect,c = geometry
          xpos = a.width-330
          balloons_local = @balloons.dup
          basey = a.height - 20
          balloons_local.each do |balloon|
            x, stepy = balloon.size
            basey -= (stepy + 3) 
            balloon.move(xpos, basey)
          end      
        end  
        
        def close_balloon(balloon)
          @balloons.delete(balloon)
          balloon.destroy
          align_balloons
          false
        end
       

        def add_balloon(title, body, icon = nil, time = 15000)
          balloon = Balloon.new(title,body,icon)
          balloon.eventbox.signal_connect("button-press-event") { close_balloon(balloon) }
          GLib::Timeout.add(time) { close_balloon(balloon) }
          @balloons << balloon
          align_balloons
          
        end
      end

      class Notification

        include Widget
        include ObserveAttr
      
        def initialize(p, *args)
          
          begin
            require 'dbus'
            bus  = DBus::SessionBus.instance  
          rescue Exception
          end

          if bus then
            service = bus.service('org.freedesktop.Notifications')
            proxy = service.object('/org/freedesktop/Notifications')
            proxy.introspect
            @notifier = proxy['org.freedesktop.Notifications']
            Debug.log.debug "creating notification widget using d-bus"
            @send_mode = :dbus
          elsif File.exist?("/usr/bin/notify-send") then
            @send_mode = :send
            Debug.log.debug "creating notification widget using notify-send"
          else
            @notifier = Notifier.new
            @notifier.set_stock(Gtk::Stock::OK)
            @notifier.set_visible(true)
            @notifier.set_tooltip('pyAdm')
            @send_mode = :intern
            Debug.log.debug "creating notification widget using internal popups"        
          end      
        end

        def notify(title,body,icon)
          case @send_mode
          when :dbus then
            @notifier.Notify(INDIGO_APP_NAME, 0, icon, title, body, [], {"x-canonical-append"=>['s',"true"]},-1)
          when :send then
            system("notify-send '#{title} ' '#{body}' -i #{icon}")
          when :intern then
            @notifier.add_balloon("", "<b>#{title}</b> #{body}", icon)
          end
        end


        def message=(args)
          title,body,icon = args
          notify(title, body, Res[icon])
        end
        observe_attr :message      
       
      end
    
    end

  end # some_gui
end # indigo
