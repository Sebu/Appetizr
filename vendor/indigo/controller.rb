module Indigo
  class Controller
    def self.helper(name)
      include name
    end    

    include CommandPattern
    include SomeGui::Create
    include SomeGui::Render
    include ActiveSupport::Callbacks

    helper TranslationHelper

    define_callbacks :after_initialize
     
    attr_accessor :model_name
    attr_accessor :params       # current request
    attr_accessor :session      # user session


    def show
      render
    end
    
    def initialize(name=nil)
      @current = self
      @params = {}
      @session = {}
      @model_name = name
      run_callbacks :after_initialize
      self
    end


    def berry
      SomeGui::View.widgets
    end
    
    
    def redirect_to(uri,*args)
      Dispatcher.dispatch([uri, self, *args]) 
    end
    
  
    def present
      session[:root].present
    end
      
    def quit
      session[:root].destroy
    end
    
    def hide
      session[:root].hide
    end

    def self.first(name=nil)
      @one ||= self.new(name)
    end

  end
end
