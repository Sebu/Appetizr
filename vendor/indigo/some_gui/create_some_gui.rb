

module Indigo
  module SomeGui
    module Create
   
      attr_accessor :slots, :current, :children
      
      def self.creates_widget(*names)
        names.each do | name |
          class_eval %{
            def #{name.to_s.downcase}(*args,&block)
              params = args.extract_options!
              params.to_options!

              widget = Widgets::#{name}.new(current,*args)

              widget.controller = self
              id_name = params[:id] || widget.object_id.to_s
              View.widgets[id_name] = widget
              #current.children ||= [] ## @parent.children ||= []
              #current.children <<  widget ## @parent.children <<  widget

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
      creates_widget :TrayIcon, :Box, :Link, :Dock, :Action, :Menu, :Notification, :Text, :GlArea, :Dialog, :Svg, :Spin, :Combo
      creates_widget :Tabs, :VSlider, :HSlider, :Radio, :Check, :Window, :Flow, :Stack, :Field, :Label, :Button, :Group, :Table

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
      
      def add_element(widget)
      end


      def method_missing(method,*params, &block)
        if current and current != self
           current.send(method,*params, &block)
        else
          puts "Create is missing #{method} in #{self} trying #{self.current}"
          super
        end
      end

    end
  end # some_gui
end # indigo
