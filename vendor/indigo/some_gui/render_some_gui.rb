

module Indigo
  module SomeGui
    module Render

      def render(params = {}, locals = {}, &block)
        if params.is_a?(String)
          render_file(params, true, locals)
        else
          render_file(params[:model], false, locals) 
        end
      end

      def render_file(name, partial, locals)
        @children ||= []
    
        params = {:path => 'app/views'}
    
        if partial
          @filename = "#{params[:path]}/_#{name}_view.rb"
          locals.each_pair do | k, v |
            eval "@#{k} = v"
          end
          name = "_#{name}"
        else

          #TODO: not so pretty
          #@controller = self

          @filename = "#{params[:path]}/#{name}_view.rb"
        end 

        View.widgets["#{name}_view"] = self.instance_eval(View[@filename], @filename)
      end  
    end
  end # SomeGui
end # indigo
