



module Indigo
  module Controller
    include CommandPattern
    include EventHandleGenerator
    include SomeGui::Create
    include SomeGui::Render

 
    attr_accessor :model_name
    attr_accessor :params
    attr_accessor :session
    attr_accessor :flash

    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    def initialize
      @params = {}
      @session = {}
      @flash = {}
      @model_name = self.class.to_s[0..-11] 
      after_initialize if respond_to? :after_initialize
      self
    end


    def load_context
      @parent = render :model => "#{model_name.downcase}"
    end
    
    def show
      eval "@#{model_name.downcase} = #{model_name}.active"
      #TODO: put into perform_action
      view = load_context
      view.show_all
      view
    end
    
    def perform_action(action)
      if respond_to?(action)
        send(action)
      else
        Debug.log.debug "Sorry :/ No action responded to #{action}."
      end
      #render!!!
    end
  
    def redirect_to(uri)
      Controller.redirect_to(uri, self)
    end
    
    # /model/id/action/
    def self.redirect_to(uri, object=nil)
      data = /(\/([a-z_]+)s)?(\/([a-z_]+))?(\/([a-z]*\d+))?$/.match(uri)
      model_name = data[2] ? data[2] : object.class.name[0..-11].downcase
      controller_name = "#{model_name.capitalize}Controller"
      action = data[4] || "show"
      id = data[6] || object.params[:id]
      new_controller = Kernel.const_get(controller_name).one
      new_controller.parent = object.parent if object
      new_controller.params[:id] = id 
      Debug.log.debug "\nVISIT org.indigo.indigoRuby/#{model_name}s/#{action}/#{id}"      
      Debug.log.debug "Processing #{controller_name}##{action} #{id}"
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
      View.widgets["#{model_name.downcase}_view"].hide #eval "@#{model_name.downcase}_view.hide"
    end

    module ClassMethods
      def one
        @one ||= self.new
      end
    end

  end
end


