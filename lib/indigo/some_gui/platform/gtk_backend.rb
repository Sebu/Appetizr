
require 'gtk2'
require 'optparse'

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

      def confirm(text="are you sure? (default message)", params={})
        box = Gtk::MessageDialog.new(current,
                                     Gtk::Dialog::DESTROY_WITH_PARENT, 
                                     Gtk::MessageDialog::QUESTION,
                                     Gtk::MessageDialog::BUTTONS_YES_NO,
                                     text)
        box.title= "Are you sure?"
        box.markup=text
        box.secondary_text = params[:info] || nil
        value = nil
        box.run { |r| value = r }
        box.destroy
        value == Gtk::Dialog::RESPONSE_YES
      end
      def input(text="")
        dialog = Gtk::Dialog.new("Input Dialog",
                                 current,
                                 Gtk::Dialog::DESTROY_WITH_PARENT,
                                 [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_NONE ])
        input_text = Gtk::Entry.new
        input_text.text=text
        dialog.vbox.add(input_text)
        dialog.show_all
        dialog.run
        new_text = input_text.text
        dialog.destroy
        new_text
      end
      
  end # Controller
  class ApplicationController < Indigo::Controller

    def initialize(args)
      super
      @args = args
      @opts = OptionParser.new
    end
    
    def option(*args,&block)
      args = args.collect do |arg| arg.is_a?(Symbol) ? "--#{arg.to_s}" : arg end
      @opts.on(*args, &block)
    end

    def parse_options
      @opts.parse(@args)
    end
    
          
    def main_loop
      Gtk.main
    end
  end

  module SomeGui
    module Widgets


      # TODO: move into own module/file
      #  "important" "undo" "redo" "info/hint" "error" "unlocked" "locked"
      STOCK_ITEMS = {:ok=> Gtk::Stock::OK, :cancel => Gtk::Stock::CANCEL, :add => Gtk::Stock::ADD, :undo => Gtk::Stock::UNDO, :quit => Gtk::Stock::QUIT}
      module Widget
        
        def get_stock(name)
          app_internal_res = "#{APP_DIR}/resources/images/#{name}.svg"
          name = app_internal_res if File.exist? app_internal_res
          app_internal_res = "#{APP_DIR}/resources/images/#{name}.png"
          name = app_internal_res if File.exist? app_internal_res
          STOCK_ITEMS[name.to_sym] || name
        end
        
        def background=(value)
          [Gtk::StateType::NORMAL, Gtk::StateType::PRELIGHT, Gtk::StateType::PRELIGHT].each do |state|
            color = Gdk::Color.parse(value)
            self.modify_bg(state, color)
          end
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

        def cleanup
          children.each {|child| remove(child) } 
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
            context.drop_finish(@controller.send(method,*(args+data)), time) 
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

      
        def connect_common_signals
        end      

        def parse_params(params)
          connect_common_signals
          self.height_request = params[:height] if params[:height]
          self.width_request = params[:width] if params[:width]
          #windowOpacity =  params[:opacity] || 1.0
        end
      end

      class Gtk::StatusIcon
        include Widget

        def toplevel?
          true
        end        

        def add_context(menu)
          signal_connect_after('popup-menu') do |w, button, time|
            if button == 3   # left mouse button
              menu.show_all
              menu.popup(nil, nil, button, time)
            end
          end  
        end
      end
      
      class TrayIcon < Gtk::StatusIcon
        def initialize(p, title="menu")
          super()
          set_stock(Gtk::Stock::OK)
          set_visible(true)
          set_tooltip(title)
        end
      end
      

      
      
      class Gtk::ImageMenuItem
        include Signaling
#       include EventHandleGenerator
        attr_accessor :controller
      end
      
     
      class Gtk::Menu
        include Widget
        attr_accessor :text
        
        def add_element(w)
          sub_menu = Gtk::ImageMenuItem.new(get_stock(w.text))
          sub_menu.submenu=w
          append(sub_menu)
        end
        
        def separator
          append(Gtk::SeparatorMenuItem.new)
        end
        
        def action(text, method=nil, *args, &block)
          new_action = Gtk::ImageMenuItem.new(get_stock(text))
          method ||= "/#{text.to_s.tr(' ','_')}"
          new_action.controller=@controller
          new_action.signal_mappings[:click]=:activate
          new_action.on :click, method, *args, &block
          append(new_action) 
        end
        
      end

      class Menu < Gtk::Menu
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
      end
      

      class Gtk::RadioButton
        include Widget
        include ObserveAttr
#       include EventHandleGenerator
        def connect_common_signals
          self.signal_mappings[:click] = :toggled
        end
      end
      class Radio < Gtk::RadioButton
        def initialize(p, state, title=nil, group=nil)
          if title 
            super(get_stock(title))
          else 
            super()
          end
          self.active=state
          self.set_group(group) if group
        end      
      end      
      

      class Gtk::CheckButton
        include Widget
        include ObserveAttr
#       include EventHandleGenerator
        def connect_common_signals
          self.signal_mappings[:click] = :toggled      
        end
      end
      class Check < Gtk::CheckButton
        def initialize(p, state, title=nil)
          if title 
            super(get_stock(title))
          else 
            super()
          end
          self.active=state
        end      
      end

      # qbutton with extra decoration via layout
      class Gtk::Button
        include Widget
        include ObserveAttr
#       include EventHandleGenerator

        def connect_common_signals
          self.signal_mappings[:click] = :clicked
        end
        def parse_params(params)
          method_click = params[:click] 
          case method_click
          when String
            signal_connect(:clicked) { Dispatcher.dispatch([method_click,@controller]) } #@controller.visit method_click }
          when Symbol
            signal_connect(:clicked) { @controller.send(method_click) }
          end
          super
        end

        def add_element(w)
          child.pack_start(w, false, false,0) if @layout
        end
      end      
      class Button < Gtk::Button
        def initialize(p, title=nil)
          if title 
            super(get_stock(title))
          else 
            super()
          end

          unless title       # CONTAINER layout
            @layout = Gtk::VBox.new 
            @layout.spacing = 0
            add(@layout)
          end
        end      
      end  


      class Gtk::TextView
        include Widget
        include ObserveAttr
          
        def parse_params(params)
          self.editable = params[:value] || true
          self.wrap_mode = Gtk::TextTag::WRAP_WORD
          super
        end
        def text(value)
          self.buffer.insert_at_cursor("#{value.to_s}\n")
        end
      end
      
      class TextView < Gtk::TextView
        def initialize(p, text=nil)
          super()
          outer_widget = Gtk::ScrolledWindow.new
          outer_widget.name = text
          outer_widget.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
          outer_widget.add(self)          
          p.add_element(outer_widget)
        end
      end
      
            
      
      class Gtk::TreeView 
        include Widget
        attr_accessor :title, :headers

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
        
        def add_context(menu)
          signal_connect('button_press_event') do |w, event|
            if event.button == 3   # left mouse button
              menu.show_all
              menu.popup(nil, nil, event.button, event.time)
            end
          end  
        end

        # TODO: move/extract edit into controller
        def column(col, name, type, edit=false, attributes=nil)
          headers ||= []
          headers << name
          renderer=nil
          case type.to_s
          when "String"
            renderer = Gtk::CellRendererText.new
            if edit
              renderer.editable = true 
              renderer.signal_connect(:edited) do |renderer, path, value|
                model.set_value(path, col, value)
              end
            end
            attributes ||= {:markup => col}
          when "TrueClass"
            renderer = Gtk::CellRendererToggle.new
            if edit
              renderer.signal_connect(:toggled) do |renderer, path|
                value = model.get_value(path, col)
                model.set_value(path, col, !value) if @controller.confirm
              end
            end
            attributes ||= {:active => col}
          when "icon"
            renderer = Gtk::CellRendererPixbuf.new
            attributes ||= {:pixbuf => col}
          end

          column=Gtk::TreeViewColumn.new(name, renderer, attributes)
          append_column(column)
        end

      end
      
      class Table < Gtk::TreeView
        
        def initialize(p, title="table")
          super()
          @headers = nil
          outer_widget = Gtk::ScrolledWindow.new
          outer_widget.name = title

          outer_widget.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
          outer_widget.add(self)
          p.add_element(outer_widget)
          self.selection.mode = Gtk::SELECTION_MULTIPLE
          self.model = nil
          self.rules_hint = true
          signal_connect('button_press_event') do |w, event|
            if event.button == 3   # left mouse button
              path, col = get_path_at_pos(event.x, event.y)
              emit :cell_clicked, self.model[path] if path
            end
          end            
        end      
      end
      
      
      class Gtk::Notebook
        include Widget 

        TAB_POSITIONS = {:bottom => Gtk::POS_BOTTOM,:top => Gtk::POS_TOP,:left => Gtk::POS_BOTTOM,:right =>Gtk::POS_RIGHT}

        def parse_params(params)
          super
          self.tab_pos= TAB_POSITIONS[ params[:position] || :top ]
        end

        def add_element(w)
          append_page(w, Gtk::Label.new(w.name))
        end
      end
      
      class Tabs < Gtk::Notebook
        def initialize(p)
          super()
        end      
      end
      
      
      class Gtk::Entry
        include Widget
        include ObserveAttr
        observe_attr :text    

        def connect_common_signals
          signal_connect(:changed) { emit("text_changed", self.text) }
#          signal_connect(:activate) { emit(:enter) }        
          self.signal_mappings[:enter] = :activate
        end
                
        def completion=(model)
          @new_completion = Gtk::EntryCompletion.new
          @new_completion.model = model
          @new_completion.text_column = 1
          renderer = Gtk::CellRendererText.new
          renderer.set_property('foreground-gdk', Gdk::Color.parse('#999999') )
          @new_completion.pack_start(renderer, :text=>2)
          @new_completion.add_attribute(renderer, :text, 2)
          @new_completion.signal_connect("match-selected") do puts self.text; emit("text_changed", self.text); emit(:enter) end
          set_completion(@new_completion)
        end
      end
      
      class Entry < Gtk::Entry
        def initialize(p, title=nil)
          super()
          self.tool_tip=title if title
          self.text=title if title
        end
      end
      

      class Gtk::Label
        include Widget
        include ObserveAttr

        def parse_params(params)
          @font_size =  params[:size] || 10 
          super
        end

        def markup=(value)
          set_markup(value.to_s)
        end
      end
      
      class Label < Gtk::Label
        def initialize(p, text=nil)
          super()
          self.markup=text
        end
      end


      class Gtk::EventBox
        include Widget
        def connect_common_signals
          self.signal_mappings[:click] = "button-press-event"  
        end       
      end
      
      class Box <  Gtk::EventBox
        include Widget
        
        def initialize(p)
          super()
          @layout = Gtk::VBox.new 
          @layout.spacing = 0
          add(@layout)

        end
        
        def add_element(w)
          child.pack_start(w, false, false,0)
#         add(w)
        end
      end      
      
      class Gtk::Expander
        include Widget      
        # TODO: extract
        def connect_common_signals
          self.signal_mappings[:click] = "button-press-event"    
        end   
                
        def parse_params(params)
          self.spacing = params[:spacing] || 0
          @padding = params[:padding] || 0
          super
        end

        def add_element(w)
          add(w)
        end      
      end
      
      class Expander < Gtk::Expander
        def initialize(p, title="")
          super(title)
          self.expanded= true
          self.name = title
        end      
      end
      
      class Gtk::Box
        include Widget
        attr_accessor :title, :padding
        
        
        
        def connect_common_signals
          self.signal_mappings[:click] = "button-press-event"
        end        
        # TODO: extract
        def parse_params(params)
          self.spacing = params[:spacing] || 0
          self.padding = params[:padding] || 0
          super
        end

        def add_element(w)
          pack_start(w, false, false, @padding)
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
      
      class Form < Stack
        def initialize(p, model)  
          super('form')
          self.add(check false, "test")
        end
      end

      class Gtk::Dialog
        include Widget
        include ObserveAttr

        observe_attr :title

        def parse_params(params)
          width = params[:width]
          height = params[:height] 
          super
        end
        def connect_common_signals
#          signal_connect('delete_event') { Gtk.main_quit }
#          signal_connect("destroy") { Gtk.main_quit } # required by gtk        
        end
        def add_element(w)
          child.add(w)
        end
      end

      class Dialog < Gtk::Dialog
        def initialize(p, title="dialog")
          case p
          when Gtk::Window
            super(title,p)
          else
            super(title)
          end

          self.title=title
        end
      end
          


      class Gtk::Window
        include Widget
        include ObserveAttr

        attr_accessor :menubar, :status_bar
        observe_attr :title
        
        def status=(value)
          context_id = status_bar.get_context_id("bla")
          status_bar.push(context_id, value)
        end
        
        # generate a statusbar
        def statusbar
          @status_bar ||= Gtk::Statusbar.new
          @layout.pack_end(@status_bar, false, false)
        end

        def parse_params(params)
          posx = params[:posx] || 100 
          posy = params[:posy] || 100
          width = params[:width]
          height = params[:height] 
          setGeometry(posx, posy, width, height) if width and height
          super
        end

        def connect_common_signals
          signal_connect('delete_event') { Gtk.main_quit }
          signal_connect("destroy") { Gtk.main_quit } # required by gtk        
        end
        
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
      end
      
      class Window < Gtk::Window
        def initialize(p, name="window")
          super()
          self.window_position = Gtk::Window::POS_CENTER
          self.title=name
          self.menubar ||= Gtk::MenuBar.new
          @layout = Gtk::VBox.new
          self.add(@layout)
          @layout.pack_start(menubar, false, false)
        end      
      end
      
      
    end # widgets
  end # some_gui
end # indigo
