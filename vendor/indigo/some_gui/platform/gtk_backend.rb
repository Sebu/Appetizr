
require 'gtk2'



module Indigo

module Controller

    def confirm(text, params={})
      box = Gtk::MessageDialog.new(current.widget,
                                   Gtk::Dialog::DESTROY_WITH_PARENT, 
                                   Gtk::MessageDialog::QUESTION,
                                   Gtk::MessageDialog::BUTTONS_YES_NO,
                                   text)
      box.title= "Are you sure?"
      box.secondary_text = params[:info] || nil
      value = nil
      box.run { |r| value = r }
      box.destroy
      value == Gtk::Dialog::RESPONSE_YES
    end
    
end

module SomeGui

    class Application

      def initialize(args)
      end
      def main_loop
        Gtk.main
      end
    end
        
  module Widgets

    module Widget
      attr_accessor :widget

      def background=(value)
        widget.modify_bg(Gtk::StateType::NORMAL, Gdk::Color.parse(value))
      end
      def status_tip=(value)
      end
      def tool_tip=(value)
      end

      def drag_delete(method, *args)
        widget.signal_connect("drag-data-delete") do |w, widget, drag_context|
           @controller.send(method, *args)
        end
      end

      
      def drop(method, *args)
        Gtk::Drag.dest_set(widget, Gtk::Drag::DEST_DEFAULT_ALL,  [['text/json', 0, 0]], Gdk::DragContext::ACTION_MOVE | Gdk::DragContext::ACTION_COPY )

        widget.signal_connect("drag-data-received") do |w, context, x, y, selection_data, info, time|
            data = ActiveSupport::JSON.decode(selection_data.data)
            @controller.send(method,*(args+[data]))
        end
      end
      
      
      def drag(method, *args)
        #Gtk::Drag.source_set(widget, Gdk::Window::SHIFT_MASK, [['text/json', 0, 0]], Gdk::DragContext::ACTION_COPY)
        Gtk::Drag.source_set(widget, Gdk::Window::BUTTON1_MASK, [['text/json', 0, 0]],  Gdk::DragContext::ACTION_MOVE)
        widget.signal_connect("drag-data-get") do |w, drag_context, selection_data, info, time|
          if method == :direct
            data = *args
          else
            data = @controller.send(method,*args)
          end
          selection_data.set(Gdk::Selection::TYPE_STRING, data.to_json)
        end
      end
      

      def gtk_class_name
        widget.class.name
      end

      def add(w)
        add_element(w)
      end
      
      def parse_params(params)
        widget.height_request = params[:height] if params[:height]
        widget.width_request = params[:width] if params[:width]
        #@widget.windowOpacity =  params[:opacity] || 1.0
      end
    end


    class Menu
      include Widget
      attr_accessor :text
      
      def initialize(p, title="menu")
        menu = self.widget = Gtk::Menu.new
        self.text = title
        case title
        when "context"
          p.widget.signal_connect('button_press_event') do |w, event|
            if event.button == 3   # left mouse button
                menu.show_all
                menu.popup(nil, nil, event.button, event.time)
            end
          end          
        else
          p.add_element(self) 
        end
      end
      
      def add_element(w)
        case w.class.name
        when "Indigo::SomeGui::Widgets::Menu"
          sub_menu = Gtk::MenuItem.new(w.text)
          sub_menu.submenu=w.widget
          widget.append(sub_menu)
        when "Indigo::SomeGui::Widgets::Action"
          widget.append(w.action)  
        end
      end
      
      def separator
        widget.append(Gtk::SeparatorMenuItem.new)
      end
      
    end

    class Action
      include Widget
      attr_accessor :action

      def initialize(p, text, method, *args)
        self.action = Gtk::MenuItem.new(text)
        action.signal_connect(:activate)  { |w| @controller.redirect_to(method) }
        p.add_element(self) 
      end
    end
    
    

    # qbutton with extra decoration via layout
    class Button 
      include Widget
      include ObserveAttr
      include EventHandleGenerator

      def text=(value) 
        widget.label = value
      end

      def text
        widget.label
      end

      
      def initialize(p, *args)
        self.widget = Gtk::Button.new
        widget.signal_connect(:clicked) { emit(:click) }
        
        # CONTAINER layout
        @layout = Gtk::VBox.new 
        @layout.spacing = 0
        #@layout.margin = 0
        widget.add(@layout)
        p.add_element(self)
        self.text=args[0]
      end


      def parse_params(params)
        method_click = params[:click]
        widget.signal_connect(:clicked) { @controller.redirect_to method_click } if method_click
  #      @widget.setMinimumSize( Qt::Size.new(height, height) ) if height
        #@widget.setMaximumSize( Qt::Size.new(60,60) )
        #click(method_click) if method_click
        super
      end

      def add_element(w)
        @layout.add(w.widget)
      end

    end



    class Table 
      include Widget

      def initialize(p)
        self.widget = Gtk::TreeView.new
        renderer = Gtk::CellRendererText.new

        #@widget.selectionBehavior=Qt::AbstractItemView::SelectRows
        #@widget.selectionMode=Qt::AbstractItemView::MultiSelection
        p.add_element(self) 
        model = nil
      end
      def model=(model)
        @widget.model=model
      end
      def model
        @widget.model
      end
      def selection
      #  indices = @widget.selectionModel ? @widget.selectionModel.selectedRows : []
      #  indices.collect{ |i| @widget.model.data_raw(i) }
      end
      
      def select_all
      #  topLeft = model.index(0, 0, @widget.parent)
      #  bottomRight = model.index(model.rowCount-1, model.columnCount-1)
      #  selection =  Qt::ItemSelection.new(topLeft, bottomRight)
      #  widget.selectionModel.select(selection, Qt::ItemSelectionModel::Select)
      end

      def column(col, type, params={})
        case type
        when :Text
          return
        end
        #@delegate = eval "#{type.to_s}D.new"
        #@delegate.controller = @controller
        #@delegate.filter_func = params[:filter]
        #@widget.setItemDelegateForColumn(col, @delegate)
      end

    end
    
    class Text
      include Widget
      include ObserveAttr


      def initialize(p, text=nil)
        self.widget = Gtk::TextView.new
        # widget.buffer.create_tag("b", {"weight" => Pango::WEIGHT_BOLD})

        p.add_element(self)
        self.text=text
      end
      def parse_params(params)
        widget.editable = params[:value] || true
        widget.wrap_mode = Gtk::TextTag::WRAP_WORD
        super
      end
      def text=(value)
        widget.buffer.insert_at_cursor("#{value.to_s}")
      end
    end
    
    class Tabs
      include Widget 

      def add(title, element)
        add_tab(element, title)
      end
      def add_element(w)
       #add_tab(w, (w.class.name || ""))
      end
            
      def initialize(p, *args)
        self.widget = Gtk::Notebook.new
        p.add_element(self) 
      end
      
      protected 
      def add_tab(w, text)
        widget.append_page(w.widget, Gtk::Label.new(text))
      end
    end
    
    class Field 
      include Widget
      include ObserveAttr

      def initialize(p, text=nil)
        self.widget = Gtk::Entry.new
        widget.signal_connect(:changed) { emit("text_changed", self.text) }
        widget.signal_connect(:activate) { emit(:enter) }
        p.add_element(self)
        self.text=text
      end

      def completion=(value)
        #@completer = Qt::Completer.new(value)
        #@completer.case_sensitivity = Qt::CaseInsensitive
        #@widget.setCompleter(@completer)
      end

      def text=(value)
        widget.set_text(value.to_s)
      end
      observe_attr :text
      
      def text
        widget.text
      end
    end
    

    class Label
      include Widget
      include ObserveAttr

      def initialize(p, text=nil)
        @widget = Gtk::Label.new
        p.add_element(self)
        self.text=text
      end
      def parse_params(params)
        @font_size =  params[:size] || 10 
        super
      end

      def text=(value)
        widget.set_markup(value.to_s)
      end
      def text
        widget.text
      end
    end
    
    
    class Layout
      include Widget
      
      def spacing=(value)
        widget.spacing=value
      end

      def margin=(value)
        #widget.margin=value
      end

      # TODO: extract
      def parse_params(params)
        spacing = params[:spacing] || 1
        margin = params[:margin] || 1
        super
      end
      
      def add_element(w)
        widget.pack_start(w.widget, true, false, 0)
      end
    end
    
    class Stack < Layout
      include Widget
      
      def initialize(p)
        self.widget = Gtk::VBox.new
        p.add_element(self) 
      end

      def stretch
      end
    end


    class Flow < Layout
      include Widget
      
      def initialize(p)
        self.widget = Gtk::HBox.new
        p.add_element(self) 
      end

      def stretch
      end
    end

    

    class Dialog 
      include Widget
      include ObserveAttr

      def initialize(p, title)
        self.widget = Gtk::Dialog.new(title, p.widget)
        self.text=title
      end

      def parse_params(params)
        width = params[:width]
        height = params[:height] 
        super
      end

      def text=(value) 
        widget.set_title(value)
      end
      def text
        widget.title
      end
      observe_attr :text
      

      def add_element(w)
        widget.child.add(w.widget)
      end
      def show_all
        widget.show_all
      end
      def close
        widget.hide
      end
    end
        
    class Window 
      include Widget
      include ObserveAttr

      attr_accessor :menubar, :status_bar
      
      def initialize(p, name)
        self.widget = Gtk::Window.new
        widget.signal_connect('delete_event') { Gtk.main_quit }
        widget.signal_connect("destroy") { Gtk.main_quit } # required by gtk
        self.text=name
        self.menubar ||= Gtk::MenuBar.new
        widget.add(Gtk::VBox.new)
        widget.child.pack_start(menubar,false,false)
      end

      def status=(value)
        context_id = status_bar.get_context_id("bla")
        status_bar.push(context_id, value)
      end
      
      # generate a statusbar
      def statusbar
        self.status_bar ||= Gtk::Statusbar.new
        widget.child.pack_end(status_bar,false,false)
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
        widget.set_title(value)
      end
      def text
        widget.title
      end
      observe_attr :text
      
      def add_element(w)
        case w.class.name
        when "Indigo::SomeGui::Widgets::Menu"
          sub_menu = Gtk::MenuItem.new(w.text)
          sub_menu.submenu=w.widget
          menubar.append(sub_menu)
        else
          widget.child.add(w.widget)
        end
      end
      def show_all
        super
        widget.show_all
      end
      
      def close
        widget.destroy
      end
      
      def hide
        widget.hide
      end
    end
    
  end # widgets
end # some_gui
end # indigo
