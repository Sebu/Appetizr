

module Indigo
module SomeGui
  module CreatesWidgets

    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    def gen_accessor(name, widget)
      eval "@#{name} = widget"
    end

    module ClassMethods
      def create_widget(*names)
        names.each do | name |
          class_eval %{

            def #{name.to_s.downcase}(*args,&block)
              params = args.extract_options!
              params.to_options!

              widget = Widgets::#{name}.new(@parent,*args)
              widget.controller = @controller
              gen_accessor(params[:id], widget) if params[:id]

              @parent.children ||= Hash.new
              @parent.children[params[:id]] = widget
              @parent, widget.parent = widget, @parent
              widget.parse_params(params)
              widget.parse_block(&block)
              @parent = widget.parent
              widget
            end

          }
        end 
      end
    end
  end

  module Create
    include CreatesWidgets

    create_widget :GlArea, :Dialog, :Svg, :Spin, :Combo, :Tabs, :VSlider, :HSlider, :Radio, :Check, :Window, :Flow, :Stack, :Field, :Label, :Button, :Group, :Table
    
    attr_accessor :children
    attr_accessor :parent

    def add_element(widget)
    end

    def name(model, name)
      eval "@#{name} = model"
    end

    def method_missing(method,*params)
      if @parent.respond_to?(method)
         @parent.send(method,*params)
      end
    end

  end


end
end
