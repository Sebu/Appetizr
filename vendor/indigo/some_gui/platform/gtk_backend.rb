




module Indigo
module SomeGui

  require 'webkit'

=begin
  class Application

    def initialize(args)
    end
    def main_loop
      Gtk.main
    end
  end
=end
        
  module Widgets
    module GtkWidget
      include Widget

      attr_accessor :widget

      def gtk_class_name
        @widget.class.name.sub("Qt::","Q")
      end

      def background=(value)
        @widget.setStyleSheet("#{qt_class_name} { background-color:  #{value} }")
      end

      def status_tip=(value)
        @widget.status_tip=value
      end

      def tool_tip=(value)
        @widget.tool_tip=value
      end

      def add(w)
        add_element(w)
      end
      
      def parse_params(params)
        #@widget.windowOpacity =  params[:opacity] || 1.0
      end
    end


    # qbutton with extra decoration via layout
    class Button 
      include GtkWidget
      include ObserveAttr
      include EventHandleGenerator

      def text=(value) 
        @widget.label = value
      end

      def text
        @widget.label
      end

      
      def initialize(p, *args)
        @widget = Gtk::Button.new
        @widget.signal_connect(:clicked) { emit(:click) }
        
        # CONTAINER layout
        @layout = Gtk::VBox.new 
  #      @layout.spacing = 0
  #      @layout.margin = 0
        @widget.add(@layout)
        p.add_element(self)
        self.text=args[0]
      end


      def parse_params(params)
        method_click = params[:click]
        @widget.signal_connect(:clicked) { @controller.redirect_to method_click } if method_click
        height = params[:height]
  #      @widget.setMinimumSize( Qt::Size.new(height, height) ) if height
        #@widget.setMaximumSize( Qt::Size.new(60,60) )
        #click(method_click) if method_click
        super
      end

      def add_element(w)
        @layout.add(w.widget)
      end

    end


    class Window 
      include GtkWidget
      include ObserveAttr

      def initialize(p, name)
        @widget = Gtk::Window.new
        @webkit = Gtk::WebKit::WebView.new
        @widget.add(@webkit)
        self.text=name
      end

      def status=(value)
        @widget.statusBar.showMessage(value)
      end
      
      def statusbar
        @widget.statusBar
      end

      def parse_params(params)
        posx = params[:posx] || 100 
        posy = params[:posy] || 100
        width = params[:width]
        height = params[:height] 
        @widget.setGeometry(posx, posy, width, height) if width and height
        super
      end

      def text=(value) 
        @widget.set_title(value)
      end
      observe_attr :text
      
      def text
        @widget.windowTitle
      end

      
      def add_element(w)
        @webkit.add(w.widget)
      end
      def show_all
        super
        @widget.show_all
      end
      def hide
        @widget.hide
      end
    end
    
  end # widgets
end # some_gui
end # indigo
