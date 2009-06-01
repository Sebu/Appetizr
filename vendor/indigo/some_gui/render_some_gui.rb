

module Indigo
  module SomeGui
    module Render


      def render(params = {}, locals = {}, &block)
        @children ||= []
        name =  if params.is_a?(String)
                  render_partial(params, locals)
                else
                  @filename = "app/views/#{model_name}_view.rb"
                  model_name
                end

        if block_given?
          befor = @current
          @current = params[:update] if params[:update]
          @current.widget.children.each {|child| @current.widget.remove(child) }
          out = instance_eval(&block)
          @current = befor
        else
          out = instance_eval(View[@filename], @filename)
        end
        if params.empty?
          @current = session[:root] = out
          out.show_all
        end
        out
      end


      def render_partial(name, locals)
        @filename = "app/views/_#{name}_view.rb"
        locals.each_pair do |k, v|
          eval "@#{k} = v"
        end
        "_#{name}"      
      end
     

    end
  end # SomeGui
end # indigo
