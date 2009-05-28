

module Indigo
  class Controller
    include CommandPattern
    include EventHandleGenerator
    include SomeGui::Create
    include SomeGui::Render
    include ActiveSupport::Callbacks

    define_callbacks :after_initialize

 
    attr_accessor :model_name
    attr_accessor :params       # current request
    attr_accessor :session      # user session
    #attr_accessor :flash        # flash data

    def initialize
      @current = self
      @params = {}
      @session = {}
      @flash = {}
      @model_name = self.class.name.sub("Controller","").downcase.freeze
      run_callbacks :after_initialize
      self
    end

    def self.helper(name)
      include name
    end

    def load_context
      self.current = render :model => "#{model_name}"
    end
    
    def view
      SomeGui::View.widgets
    end
    
    def show
      instance_variable_set("@#{model_name}", model_name.camelize.constantize.active)
      #TODO: put into perform_action
      controller_view = session[:root] = load_context
      controller_view.show_all
      controller_view
    end
    
    def perform_action(action)
      if respond_to?(action)
        send(action)
      else
        Debug.log.debug "  \e[1;91mSorry\e[0m :/ No action responded to \e[1m#{action}\e[0m"
      end
      #render!!!
    end
  
    def redirect_to(uri)
      Controller.redirect_to(uri, self)
    end
    
    # /model/id/action/
    def self.redirect_to(uri, object=nil)
      data = /(\/([a-z_]+)s)?(\/([a-z_]+))?(\/([a-z]*\d+))?$/.match(uri)
      
      model_name = data[2] ? data[2] : object.model_name.downcase
      controller_name = "#{model_name.capitalize}Controller"
      action = data[4] || "show"
      id = data[6] || object.params[:id]

      new_controller = Kernel.const_get(controller_name).one
      new_controller.current = object.current  if object
      new_controller.params[:id] = id 

      Debug.log.debug "\n  \e[1;36mVISIT\e[0m \e[4morg.indigo.indigoRuby/#{model_name}s/#{action}/#{id}\e[0m"      
      Debug.log.debug "  Processing #{controller_name}##{action} #{id}"
      new_controller.perform_action(action)
    end
    
    
    def t(*params)
      I18n.t(*params)
    end

    def l(*params)
      I18n.l(*params)
    end

    def present
      session[:root].widget.present
    end
      
    def close
      session[:root].close
    end
    
    def hide
      session[:root].hide
    end

    def self.one
      @one ||= self.new
    end

  end
end


