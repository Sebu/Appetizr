

module Indigo
  class Controller
    include CommandPattern
    include EventHandleGenerator
    include SomeGui::Create
    include SomeGui::Render
    include ActiveSupport::Callbacks

    define_callbacks :after_initialize

 
    attr_accessor :model_name
    attr_accessor :params
    attr_accessor :session
    attr_accessor :flash

    def initialize
      @current = self
      @params = {}
      @session = {}
      @flash = {}
      @model_name = self.class.name.sub("Controller","").downcase.freeze
      #after_initialize if respond_to? :after_initialize
      self
    end


    def load_context
      self.current = render :model => "#{model_name}"
    end
    
    def show
      instance_variable_set("@#{model_name}", model_name.camelize.constantize.active)
#     eval "@#{model_name.downcase} = "
      #TODO: put into perform_action
      view = session[:view] = load_context
      view.show_all
      view
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
    #region: actions

    def close
      session[:view].close
    end
    
    def hide
      session[:view].hide
    end

      def self.one
        @one ||= self.new
      end

  end
end


