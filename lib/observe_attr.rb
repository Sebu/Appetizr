
module Indigo
module ObserveAttr
  

  def self.included(base)
    base.class_eval do
      extend ObserveAttr::ClassMethods
    end
  end

  #  TODO: change syntax and uniform the a <==> b
  def observe(m2, key2, m1, key1, options={})
    options.to_options!

    #puts "#{m2} #{key2} #{m1} #{key1}"    

    signal = m1.class.obs_calls[key1.to_sym][:signal]
    func = m2.class.obs_calls[key2.to_sym][:func]

    controller = options[:controller] || @controller

    #TODO: prep filter chain
    # options[:filter].each do | f |
    # filter_chain = controller.send(f, gen_filter_chain next )
    if options[:filter]
      m1.connect(signal) {|args| m2.send(func, controller.send(options[:filter],args) ) }
      m2.send( func, controller.send(options[:filter],m1.send(key1)) ) 
    else
      m1.connect(signal, m2, func)
      m2.send( func, m1.send(key1)) 
    end
  end

  module ClassMethods
    attr_accessor :obs_calls

    def obs_attr(name, params = {})
      signal = "#{name}_changed"
      func = "#{name}="
      default_params = {:signal => signal, :func => func, :override=> false}
      params = default_params.merge(params)

      @obs_calls ||= {}
      @obs_calls[name] = params

      class_eval %{
        def #{name}_observe(model,key,params={})
          observe(self, "#{name}".to_sym, model, key, params)
        end

        if not params[:override]
          def #{func}(value)
            @#{name}_was=@#{name}
            @#{name}=value
            emit "#{params[:signal]}", value
            #super
          end
          def #{name}
            @#{name}
          end
          def #{name}_was
             @#{name}_was
          end
        else
          def #{func}(value)
            super
            emit "#{params[:signal]}", value
          end
        end
      }
    end
  end
end
end

