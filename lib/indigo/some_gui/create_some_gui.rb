

module Indigo
  module SomeGui
    module Create
   
      attr_accessor :slots, :current, :berry, :autolayout
      
      def self.creates_widget(*names)
        names.each do | name |
          class_eval %{
            def #{name.to_s.downcase}(*args,&block)
              params = args.extract_options!
              params.to_options!

              widget = Widgets.const_get("#{name}").new(current,*args)

              widget.controller = self
              id_name = params[:id]
              View.widgets[id_name] = widget if id_name
              current.berry ||= {}
              current.berry[id_name] = widget if id_name

              unless !self.autolayout or widget.toplevel? or (widget.respond_to?(:parent) and widget.parent)
                current.add_element(widget) 
              end                
              self.autolayout=true

              self.slots ||= []
              slots.push current
              self.current = widget
              widget.parse_params(params)
              parse_block(&block)
              widget.block_end

              ## pop
              self.current = slots.pop
              widget.respond
            end

          }
        end 
      end
      creates_widget :Expander, :TrayIcon, :Box, :Link, :Dock, :Menu, :Notification, :TextView, :GlArea, :Dialog, :Svg, :Spin, :Combo
      creates_widget :Tabs, :VSlider, :HSlider, :Radio, :Check, :Window, :Flow, :Stack, :Entry, :Label, :Button, :Group, :Table

      def ignore_next
        self.autolayout = false
      end
      #def <<(widget)
      #  @current.add_element(widget)
      #end
      
      def field(*args)
        options = args.extract_options!
        options.to_options!
        model, name = args
        data = model.send(name)
        case data
        when String
          entry data
        when Fixnum
          puts "spin"
        when TrueClass,FalseClass
          check data         
        end
      end
      
      def gen_accessor(name, widget)
        instance_variable_set(name, widget)
      end
      
      def parse_block(&block)
        if block_given?
          current.block = block
          block.call self.current
        end
      end
          
      def model(value)
        current.model=value
      end

      def update(name, &block)
        render(:update=>berry[name], &block)
      end
            
      def from_file(filename)
        builder = Gtk::Builder.new
        builder.add("app/views/#{filename}")
        builder.connect_signals do |handler| Proc.new{ Dispatcher.dispatch([handler,self,nil]) } end
        builder.objects.each do |object| 
          object.controller=self
          object.connect_common_signals
          object.parse_params({})
          object.block_end
          View.widgets[object.name] = object
        end
        self.current = builder.get_object("main").show
      end
      
      def add_element(widget)
      end
      

      def method_missing(method,*params, &block)
        if current and current != self
           current.send(method,*params, &block)
        else
          #puts "Create is missing #{method} in #{self} trying #{self.current}"
          super
        end
      end

    end
  end # some_gui
end # indigo
