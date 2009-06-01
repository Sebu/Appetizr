

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
    
    # /model/id/action/
    def dispatch(request)
      uri, sender, *args = request # currently the request is only the uri and the sender
      data = /(([a-z_]+)s)?(\/([a-z_]+))?(\/([a-z]*\d+))?$/.match(uri)
      
      model_name = data[2] ? data[2] : sender.model_name.downcase
      controller_name = "#{model_name.capitalize}Controller"
      action = data[4] || "show"
      id = data[6] || sender.params[:id]
      new_controller = Kernel.const_get(controller_name).one
      new_controller.current = sender.current  if sender
      new_controller.params[:id] = id 

      Debug.log.debug "\n  \e[1;36mVISIT\e[0m \e[4morg.indigo.indigoRuby/#{model_name}s/#{action}/#{id}\e[0m"      
      Debug.log.debug "  Processing #{controller_name}##{action} #{id}"
      
      new_controller.perform_action(action, *args)
    end

  end
end


