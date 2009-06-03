
require 'gtk2'



module Gtk
  class TreeSelection
    def to_a
      selected = []
      selected_each { |model, path, iter| selected << model[path] }
      selected    
    end
    def remove
      selected_each { |model, path, iter| model.remove(iter) }
    end
  end
end


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

        def get_stock(name)
          STOCK_ITEMS[name.to_sym] || name
        end

        def background=(value)
          self.modify_bg(Gtk::StateType::NORMAL, Gdk::Color.parse(value))
        end
        
        def status_tip=(value)
        end
        
        def add_context(menu)
          signal_connect('button_press_event') do |w, event|
            if event.button == 3   # left mouse button
              menu.show_all
              menu.popup(nil, nil, event.button, event.time)
            end
          end  
        end
        
        def tool_tip=(value)
          self.tooltip_markup=value
        end

        def drag_delete(method, *args)
          signal_connect("drag-data-delete") do |w, context|
            @controller.send(method, *args) if context.drag_drop_succeeded?
          end
        end

        
        def drop(method, *args)
          Gtk::Drag.dest_set(self, Gtk::Drag::DEST_DEFAULT_ALL,  [['application/json', 0, 0]], Gdk::DragContext::ACTION_MOVE | Gdk::DragContext::ACTION_COPY )
          signal_connect("drag-data-received") do |w, context, x, y, selection_data, info, time|
            data = ActiveSupport::JSON.decode(selection_data.data)
            context.drop_finish(@controller.send(method,*(args+[data])), time) 
          end
        end
        
        
        def drag(*args)
          method = (args.first.is_a?(Symbol) and @controller.respond_to?(args.first)) ? args.shift : nil
          Gtk::Drag.source_set(self, Gdk::Window::BUTTON1_MASK, [['application/json', 0, 0]],  Gdk::DragContext::ACTION_MOVE | Gdk::DragContext::ACTION_COPY)
          signal_connect("drag-data-get") do |w, context, selection_data, info, time|
            if method
              data = @controller.send(method, *args)
            else
              data = *args
            end
            selection_data.set(Gdk::Selection::TYPE_STRING, data.to_json)
          end

          signal_connect("drag-motion") do |w, context, x, y, time|
            if w == Gtk::Drag.get_source_widget(context)
              context.drag_status(0, time)
            else
              context.drag_status(Gdk::DragContext::ACTION_MOVE, time)
            end
          end
          
        end

        def gtk_class_name
          self.class.name
        end

      
        def parse_params(params)
          self.height_request = params[:height] if params[:height]
          self.width_request = params[:width] if params[:width]
          #windowOpacity =  params[:opacity] || 1.0
        end
      end

      class TrayIcon < Gtk::StatusIcon
        include Widget
        def initialize(p, title="menu")
          super()
          set_stock(Gtk::Stock::OK)
          set_visible(true)
          set_tooltip(title)
        end

        def toplevel?
          true
        end        

        def add_context(menu)
          signal_connect('popup-menu') do |w, button, time|
            if button == 3   # left mouse button
              menu.show_all
              menu.popup(nil, nil, button, time)
            end
          end  
        end
                
      end
      

      class Gtk::Menu
        include Widget
        attr_accessor :text
        
        def initialize(p, title=:context)
          super()
          self.text = title.to_s
          case title
          when :context
            p.add_context(self)
          else
            p.add_element(self)
          end
        end
        
        def add_element(w)
          case w.class.name
          when "Indigo::SomeGui::Widgets::Menu"
            sub_menu = Gtk::ImageMenuItem.new(get_stock(w.text))
            sub_menu.submenu=w
            append(sub_menu)
          when "Indigo::SomeGui::Widgets::Action"
            append(w.action)  
          end
        end
        
        def separator
          append(Gtk::SeparatorMenuItem.new)
        end
      end
      Menu = Gtk::Menu

      class Action
        include Widget
        attr_accessor :action

        def toplevel?
          false
        end
        
        def initialize(p, text, method=nil)
          self.action = Gtk::ImageMenuItem.new(get_stock(text))
          method ||= "/#{text.to_s.tr(' ','_')}"
          action.signal_connect(:activate) { |w| Dispatcher.dispatch([method,@controller]) } #.redirect_to(method) }
        end
      end
      

      # qbutton with extra decoration via layout
      class Button < Gtk::Button
        include Widget
        include ObserveAttr
        include EventHandleGenerator

        def initialize(p, title=nil)
          if title 
            super(get_stock(title))
          else 
            super()
          end

          signal_connect(:clicked) { emit(:click) }
          
          unless title       # CONTAINER layout
            @layout = Gtk::VBox.new 
            @layout.spacing = 0
            #@layout.margin = 0
            add(@layout)
          end
        end


        def parse_params(params)

          method_click = params[:click] 
          case method_click
          when String
            signal_connect("button-press-event") { Dispatcher.dispatch([method_click,@controller]) } #@controller.redirect_to method_click }
          when Symbol
            signal_connect("button-press-event") { @controller.send(method_click) }
          end
          super
        end

        def add_element(w)
          child.pack_start(w, false, false,0) if @layout
        end
      end      

  
      
      
      class Table < Gtk::TreeView 
        include Widget
        attr_accessor :title, :headers

        def initialize(p, title="table")
          super()
          @headers = nil
          outer_widget = Gtk::ScrolledWindow.new
          outer_widget.name = title

          outer_widget.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
          outer_widget.add(self)
          p.add_element(outer_widget)
          selection.mode = Gtk::SELECTION_MULTIPLE
          model = nil
        end
        
        def search(&block)
          set_search_equal_func {|model, columnm, key, iter|
            !block.call(iter.get_value(0), key)
          }
        end  
        
        def filter(&block)
          unless @filter
            @filter ||= Gtk::TreeModelFilter.new(self.model)
            self.model = @filter
          end
          model.set_visible_func { |model, iter|
            block.call(iter.get_value(0))
          }
          @filter.refilter
        end              
                
        def columns_from_model(*args)
          options = args.extract_options!
          options.to_options!
          headers ||= options[:headers] || model.keys
          model.types.each_with_index do |type, index|
            column(index+1, headers[index].to_s, type, model.editable[index])
          end
          
        end
    
        def select_all
          self.selection.select_all
        end

        def column(col, name, type, edit=false)
          headers ||= []
          headers << name
          column = case type.to_s
          when "String"
            renderer = Gtk::CellRendererText.new
            if edit
              renderer.editable = true 
              renderer.signal_connect(:edited) do |renderer, path, value|
                model.set_value(path, col, value)
              end
            end
            Gtk::TreeViewColumn.new(name, renderer, :markup => col)
          when "TrueClass"
            renderer = Gtk::CellRendererToggle.new
            if edit
              renderer.signal_connect(:toggled) do |renderer, path|
                value = model.get_value(path, col)
                model.set_value(path, col, !value)
              end
            end
            Gtk::TreeViewColumn.new(name, renderer, :active => col)
          end
          append_column(column)
        end

      end
      
     
      class Tabs < Gtk::Notebook
        include Widget 

        TAB_POSITIONS = {:bottom => Gtk::POS_BOTTOM,:top => Gtk::POS_TOP,:left => Gtk::POS_BOTTOM,:right =>Gtk::POS_RIGHT}
        def initialize(p)
          super()
        end
        
        def parse_params(params)
          super
          self.tab_pos= TAB_POSITIONS[ params[:position] || :top ]
        end

        def add_element(w)
          append_page(w, Gtk::Label.new(w.name))
        end
      end
      
      class Entry < Gtk::Entry
        include Widget
        include ObserveAttr

        def initialize(p, title=nil)
          super()
          signal_connect(:changed) { emit("text_changed", self.text) }
          signal_connect(:activate) { emit(:enter) }
          tool_tip=title
        end

        def completion=(model)
          new_completion = Gtk::EntryCompletion.new
          new_completion.model = model
          new_completion.text_column = 1
          renderer = Gtk::CellRendererText.new
              renderer.set_property('foreground-gdk', Gdk::Color.parse('#999999') )
          new_completion.pack_start(renderer, :text=>2)
          new_completion.add_attribute(renderer, :text, 2)
          completion= new_completion
        end

        def text=(value)
          set_text(value.to_s)
        end
       
        observe_attr :text        
      end
      

      class Label < Gtk::Label
        include Widget
        include ObserveAttr

        def initialize(p, text=nil)
          super()
          self.text=text
        end
        
        def parse_params(params)
          @font_size =  params[:size] || 10 
          super
        end

        def text=(value)
          set_markup(value.to_s)
        end
      end


      class Box <  Gtk::EventBox
        include Widget
        
        def initialize(p)
          super()
        end
        
        def add_element(w)
          add(w)
        end
      end      
      
      class Gtk::Box
        include Widget
        attr_accessor :title
        
        # TODO: extract
        def parse_params(params)
          spacing = params[:spacing] || 0
          margin = params[:margin] || 1
          super
        end

        def add_element(w)
          pack_start(w, false, false, 1)
        end
      end
      
      class Stack < Gtk::VBox
        def initialize(p,title="stack")
          super()
          self.name = title
        end
      end


      class Flow < Gtk::HBox
        def initialize(p, title="flow")
          super()
          self.name = title
        end
      end
      

      class Dialog < Gtk::Dialog
        include Widget
        include ObserveAttr

        def initialize(p, title="dialog")
          super(title,p)
          self.text=title
        end

        def parse_params(params)
          width = params[:width]
          height = params[:height] 
          super
        end

        def text=(value) 
          set_title(value)
        end
        def text
          title
        end
        observe_attr :text
        

        def add_element(w)
          child.add(w)
        end

        def close
          hide
        end
      end
          
      class Window < Gtk::Window
        include Widget
        include ObserveAttr

        attr_accessor :menubar, :status_bar
        
        def initialize(p, name="window")
          super()
          self.window_position = Gtk::Window::POS_CENTER
          signal_connect('delete_event') { Gtk.main_quit }
          signal_connect("destroy") { Gtk.main_quit } # required by gtk
          self.text=name
          self.menubar ||= Gtk::MenuBar.new
          @layout = Gtk::VBox.new
          self.add(@layout)
          @layout.pack_start(menubar,false,false)
        end

        def status=(value)
          context_id = status_bar.get_context_id("bla")
          status_bar.push(context_id, value)
        end
        
        # generate a statusbar
        def statusbar
          @status_bar ||= Gtk::Statusbar.new
          @layout.pack_end(@status_bar,false,false)
        end

        def parse_params(params)
          posx = params[:posx] || 100 
          posy = params[:posy] || 100
          width = params[:width]
          height = params[:height] 
          setGeometry(posx, posy, width, height) if width and height

          super
        end

        def text=(value) 
          set_title(value)
        end
        def text
          title
        end
        observe_attr :text
        
        def add_element(w)
          case w.class.name
          when "Indigo::SomeGui::Widgets::Menu"
            sub_menu = Gtk::MenuItem.new(w.text)
            sub_menu.submenu=w
            menubar.append(sub_menu)
          else
            child.pack_start(w, true, false,0)
          end
        end
        
       
        def close
          destroy
        end
        
        def hide
          hide
        end
      end
      
    end # widgets
  end # some_gui
end # indigo
