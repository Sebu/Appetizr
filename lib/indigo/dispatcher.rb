

module Indigo
  class Dispatcher
    
    def self.dispatcher
      @dispatcher ||= self.new
    end
    
    def self.dispatch(request)
      dispatcher.dispatch(request)
    end

    def initialize
    end
    
    def perform_action(controller, action, *args)
      if controller.respond_to?(action)
        controller.send(action, *args)
      else
        Debug.log.debug "  \e[1;91mSorry\e[0m :/ No action responded to \e[1m#{action}\e[0m"
        Debug.log.debug "  \e[1;93mTODO\e[0m implement #{controller.class.name}##{action}"
      end
    end
    
    # /model/id/action/
    def dispatch(request)
      uri, sender, *args = request # currently the request is only the uri and the sender
      data = /(([a-z_]+)s)?(\/([a-z_]+))?(\/([a-z]*\d+))?$/.match(uri)
      
      model_name = data[2]
      action = data[4] || "show"
      id = data[6] || sender.params[:id]
      new_controller = nil
      if model_name
        begin
          controller_name = "#{model_name.camelize}Controller".constantize
        rescue NameError
          controller_name = Controller
        end
        new_controller = controller_name.first(model_name)
        new_controller.current = sender.current if sender
      else
        model_name = sender.model_name
        new_controller = sender
      end
      new_controller.params[:id] = id 

      Debug.log.debug "\n  \e[1;36mVISIT\e[0m \e[4morg.indigo.indigoRuby/#{model_name}s/#{action}/#{id}\e[0m"      
      Debug.log.debug "  Processing #{new_controller.class.name}##{action} #{id}"
      
      perform_action(new_controller, action, *args)
    end

  end
end


