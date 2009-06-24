# common widget code


module Indigo
  module SomeGui
    module Widgets
    
      module Widget
        include ObserveAttr
        attr_accessor :controller, :block, :berry
        

        def add_element(widget)
        end
        def respond
          self
        end
            
        def block_end
        end
       
      end

      class Notifier #< Gtk::StatusIcon
        COLORS = {-1=>"#FF0000",0=>"#FFFFFF",1=>"#00FF00"}
        class Balloon < Gtk::Window
          attr_accessor :title, :body, :icon, :eventbox
          
          def initialize(t,b,i, color="#FFFFFF")
            super(Gtk::Window::POPUP)
            @eventbox = Gtk::EventBox.new
            @eventbox.modify_bg(Gtk::StateType::NORMAL, Gdk::Color.parse(color))
            @title = Gtk::Label.new
            title.set_markup("<span size='15000'>#{t}</span>")  

            @body = Gtk::Label.new
            body.wrap = true
            body.set_markup(b)
            
            image = Gtk::Image.new(i) #,Gtk::IconSize::DIALOG)

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
          xpos = Gdk::Screen.default.width-330
          basey = Gdk::Screen.default.height - 20
          @balloons.dup.each do |balloon|
            x, stepy = balloon.size
            basey -= (stepy + 3) 
            balloon.move(xpos, basey)
          end      
        end  
        
        def close_balloon(balloon)
          if @balloons.delete(balloon)
            balloon.destroy
            align_balloons
          end
          false
        end
       

        def add_balloon(title, body, icon, color, time = 15000)
          balloon = Balloon.new(title, body, icon, color)
          balloon.eventbox.signal_connect("button-press-event") { close_balloon(balloon) }
          GLib::Timeout.add(time) { close_balloon(balloon) }
          @balloons << balloon
          align_balloons
        end
      end

      class Notification

        include Widget
        include ObserveAttr
      
        def toplevel?
          true
        end
        
        def initialize(p, *args)
          
          begin
            require 'dbus'
            bus  = DBus::SessionBus.instance  
          rescue Exception
          end

=begin
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
=end
            @notifier = Notifier.new
            @send_mode = :intern
            Debug.log.debug "creating notification widget using internal popups"        
#         end      
        end

        def notify(title,body,icon,color)
          case @send_mode
          when :dbus then
            @notifier.Notify(INDIGO_APP_NAME, 0, icon, title, body, [], {"x-canonical-append"=>['s',"true"]},-1)
          when :send then
            system("notify-send '#{title} ' '#{body}' -i #{icon}")
          when :intern then
            puts icon
            @notifier.add_balloon(title, body, icon, Notifier::COLORS[color])
          end
        end


        def message=(args)
          title,body,icon,color = args
          notify(title, body, Res[icon], color)
        end
        observe_attr :message      
       
      end
    
    end

  end # some_gui
end # indigo
