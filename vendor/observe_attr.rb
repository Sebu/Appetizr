
#TODO: after first rewrite still not convinced :/
# add filter chain
# remove some fixed code
# add lazy reading of data
# use alias method chain

module ObserveAttr
  def self.included(base)
    base.class_eval do
      extend ObserveAttr::ClassMethods
    end
  end

  #  TODO: change syntax and uniform the a <==> b
  def observe(m1, key1, m2, key2, options={})
    options.to_options!

    #puts "#{m1} #{key1} #{m2} #{key2}"    

    # emited signal
    signal = m2.class.obs_calls[key2.to_sym][:signal]
    # reader function to call
    func = m1.class.obs_calls[key1.to_sym][:func]

    controller = options[:controller] || @controller

    #TODO: prep filter chain
    #options[:filter].each do | f |
    #filter_chain_pre = controller.send(f, gen_filter_chain next )

    if options[:fiter].is_a?(Array)
    elsif options[:filter].is_a?(Symbol) or options[:filter].is_a?(String)
      m2.connect(signal) {|args| m1.send(func, controller.send(options[:filter],args) ) }
      m1.send( func, controller.send(options[:filter],m2.send(key2)) ) 
    else
      m2.connect(signal, m1, func)
      m1.send(func, m2.send(key2)) 
    end
  end

  module ClassMethods
    attr_accessor :obs_calls


    def obsattr_reader(name, params ={})
      params = {:func => "#{name}="}.merge(params)
      @obs_calls ||= {}
      @obs_calls[name] = if @obs_calls[name]
                           @obs_calls[name].merge(params)
                         else 
                           params
                         end     
     class_eval %{
        def #{name}_observe(model,key,params={})
          observe(self, "#{name}".to_sym, model, key, params)
        end
      }
    end

    def obsattr_writer(name, params = {})
      params = {:signal => "#{name}_changed", :func => "#{name}="}.merge(params)

      @obs_calls ||= {}
      @obs_calls[name] = if @obs_calls[name]
                           @obs_calls[name].merge(params)
                         else 
                           params
                         end     

      alias_method "o_assign_#{name}", params[:func] unless params[:override]

      class_eval %{
        if not params[:override]
          def #{params[:func]}(value)
            send("o_assign_#{name}", value)
            emit "#{params[:signal]}", value
          end
        else
          def #{params[:func]}(value)
            super
            emit "#{params[:signal]}", value
          end
        end
      }
    end

    def obs_attr(name, params = {})
      obsattr_writer name, params
      obsattr_reader name, params
    end

  end
end

