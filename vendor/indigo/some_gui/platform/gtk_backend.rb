
require 'gtk2'

module Indigo

  class Controller

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
      
  end # Controller

  module SomeGui

      class Application

        def initialize(args)
        end
        def main_loop
          Gtk.main
        end
      end
          
    module Widgets

      STOCK_ITEMS = {:ok=> Gtk::Stock::OK, :cancel => Gtk::Stock::CANCEL, :add => Gtk::Stock::ADD, :undo => Gtk::Stock::UNDO, :quit => Gtk::Stock::QUIT}
      module Widget
        attr_accessor :widget

        def get_stock(name)
          STOCK_ITEMS[name.to_sym] || name
        end

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
          self.text = title.to_s
          case title
          when :context
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
            sub_menu = Gtk::ImageMenuItem.new(get_stock(w.text))
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
          self.action = Gtk::ImageMenuItem.new(get_stock(text))
          action.signal_connect(:activate)  { |w| @controller.redirect_to(method) }
          p.add_element(self) 
        end
      end
      
      

      # qbutton with extra decoration via layout
      class Button 
        include Widget
        include ObserveAttr
        include EventHandleGenerator

        #def text=(value) 
        #  widget.label = value
        #end

        #def text
        #  widget.label
        #end

        def initialize(p, *args)
          title = args[0]
          self.widget = if title 
            Gtk::Button.new(get_stock(title))
          else 
            Gtk::Button.new
          end

          widget.signal_connect(:clicked) { emit(:click) }
          
          unless title       # CONTAINER layout
            @layout = Gtk::VBox.new 
            @layout.spacing = 0
            #@layout.margin = 0
            widget.add(@layout)
          end
          p.add_element(self)
        end


        def parse_params(params)
          method_click = params[:click]
          widget.signal_connect(:clicked) { @controller.redirect_to method_click } if method_click
          super
        end

        def add_element(w)
          @layout.pack_start(w.widget, false, false,0) if @layout
        end

      end
      
      class Link < Button
        def initialize(p, *args)
          title = args[0]
          label = Gtk::Label.new
          label.set_markup("<span color='blue'><u>#{title}</u></span>")
          self.widget = Gtk::EventBox.new
          widget.add(label)
          p.add_element(self)
        end
        
        def parse_params(params)
          method_click = params[:click]
          widget.signal_connect("button-press-event") { @controller.redirect_to method_click } if method_click
          #widget.signal_connect("enter-notify-event") { puts "enter"; widget.get_window.set_cursor(Gtk::Gdk::WACTCH)  }
        end
      end


      class Table 
        include Widget
        attr_accessor :title

        def initialize(p, title="table")
          @title = title
          @scroll = self.widget = Gtk::ScrolledWindow.new
          p.add_element(self)
          @scroll.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
          self.widget = Gtk::TreeView.new
          widget.selection.mode=Gtk::SELECTION_MULTIPLE
          @scroll.add(widget)
          model = nil
        end
        def model=(model)
          widget.model=model
          #TODO enabled when many_columns/long_rows
          widget.rules_hint=true

        end
        def model
          widget.model
        end
        def selection
          selected = []
          widget.selection.selected_each { |model, path, iter| selected << model[path] }
          selected
        end
        
        def select_all
          widget.selection.select_all
        end

        def column(col, name, type, edit=false)
          column = case type
          when :string;
            renderer = Gtk::CellRendererText.new
            if edit
              renderer.editable = true 
              renderer.signal_connect(:edited) do |renderer, path, value|
                model.set_value(path, col, value)
              end
            end
            Gtk::TreeViewColumn.new(name, renderer, :markup => col)
          when :boolean;    
            renderer = Gtk::CellRendererToggle.new
            if edit
              renderer.signal_connect(:toggled) do |renderer, path|
                value = model.get_value(path, col)
                model.set_value(path, col, !value)
              end
            end
            Gtk::TreeViewColumn.new(name, renderer, :active => col)
          end
          widget.append_column(column)
        end

      end
      
      class Text
        include Widget
        include ObserveAttr


        def initialize(p, text=nil)
          self.widget = Gtk::ScrolledWindow.new
          widget.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

          @textview = Gtk::TextView.new
          widget.add(@textview)
          # widget.buffer.create_tag("b", {"weight" => Pango::WEIGHT_BOLD})

          p.add_element(self)
          self.text=text
        end
        def parse_params(params)
          @textview.editable = params[:value] || true
          @textview.wrap_mode = Gtk::TextTag::WRAP_WORD
          super
        end
        def text=(value)
          @textview.buffer.insert_at_cursor("#{value.to_s}\n")
        end
      end
      
      class Tabs
        include Widget 

        def tab(title)
          @current_title = title
        end
        def add_element(w)
          add_tab(w, @current_title)
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

        def completion=(model)
          completion = Gtk::EntryCompletion.new
          completion.model = model
          completion.text_column = 0
          widget.completion = completion
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


      class Box
        include Widget
        
        def initialize(p)
          self.widget = Gtk::EventBox.new
          p.add_element(self) 
        end
        
        def add_element(w)
          widget.add(w.widget)
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
          spacing = params[:spacing] || 0
          margin = params[:margin] || 1
          super
        end
        
        def add_element(w)
          widget.pack_start(w.widget, false, false, 1)
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
            widget.child.pack_start(w.widget, true,false,0)
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
