

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
          before = @current
          @current = params[:update] if params[:update]
          if @current.respond_to?(:children)
            @current.children.each {|child| @current.remove(child) } 
          end
          out = instance_eval(&block)
          @current = before
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
