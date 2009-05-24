

module Indigo
module SomeGui
  module CreatesWidgets

    attr_accessor :slots
    attr_accessor :current
    
    def self.included(base)
      base.class_eval do
        extend ClassMethods
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

    module ClassMethods
      def create_widget(*names)
      
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
              ## pop
              self.current = slots.pop

              widget.respond
            end

          }
        end 
      end
    end
  end

  module Create
    include CreatesWidgets

    
    create_widget :Dock, :Action, :Menu, :Notification, :Text, :GlArea, :Dialog, :Svg, :Spin, :Combo, :Tabs, :VSlider, :HSlider, :Radio, :Check, :Window, :Flow, :Stack, :Field, :Label, :Button, :Group, :Table
    
    attr_accessor :children

    def add_element(widget)
    end

    def method_missing(method,*params)
      if current and current != self
         current.send(method,*params)
      else
        puts "Create is missing #{method} in #{self} move to #{self.current}"
        super
      end
    end

  end


end
end
