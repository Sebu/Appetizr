

module Indigo
  class Controller
    include CommandPattern
    include EventHandleGenerator
    include SomeGui::Create
    include SomeGui::Render
    include ActiveSupport::Callbacks


    def self.helper(name)
      include name
    end    

    helper TranslationHelper

    define_callbacks :after_initialize
     
    attr_accessor :model_name
    attr_accessor :params       # current request
    attr_accessor :session      # user session


    def initialize
      @current = self
      @params = {}
      @session = {}
      @flash = {}
      @model_name = self.class.name.sub("Controller","").downcase.freeze
      run_callbacks :after_initialize
      self
    end



    def do_render
      session[:root] = self.current = render(:model => "#{model_name}")
      session[:root].show_all
    end
    
    def berry
      SomeGui::View.widgets
    end
    

    
    def perform_action(action, *args)
      if respond_to?(action)
        send(action, *args)
      else
        Debug.log.debug "  \e[1;91mSorry\e[0m :/ No action responded to \e[1m#{action}\e[0m"
      end
      #render!!!
    end
  
  
    def present
      session[:root].widget.present
    end
      
    def quit
      session[:root].quit
    end
    
    def hide
      session[:root].widget.hide
    end

    def self.one
      @one ||= self.new
    end

  end
end


