
require 'widgets'
require 'application'

module Indigo
  module RenderSomeGui
   include CreateSomeGui  

    def load_file(filename)
      content = ''
      File.open(filename, 'r') { |f| content = f.read }

      #Application::Base.log.debug "loading render block #{filename}"
      #Application::Base.log.debug content
      content
    end  


    def render(params = {}, locals = {}, &block)
      if params.is_a?(String)
        render_file(params, true, locals)
      else
        render_file(params, false, locals) 
      end
    end

    def render_file(name, partial, locals)
      @children ||= {}
  
      params = {:path => 'app/views'} #.merge(params)
  
      if partial
        @filename = "#{params[:path]}/_#{name}_view.rb"
        locals.each_pair do | k, v |
          eval "@#{k} = v"
        end
        name = "_#{name}"
      else

        #TODO: not so pretty
        name = self.class.to_s.downcase[0..-11].to_sym
        @parent ||= self
        @controller = self

        @filename = "#{params[:path]}/#{name}_view.rb"
      end 

      eval "@#{name}_view_content ||= load_file(@filename)"
      eval "@#{name}_view = self.instance_eval(@#{name}_view_content, @filename)"
    end  
  end
end

