

#TODO: works my ass geil
# add filter chain
# add lazy reading of data


module ObserveAttr
  include Signaling
  def self.included(base)
    base.class_eval do
      extend ObserveAttr::ClassMethods
    end
  end


  def method_missing(name, *args)
    match = /_observe/.match(name.to_s)
    if match
      observe(self, match.pre_match.to_sym, *args)
    else
      super
    end
  end

  #  TODO: change syntax and uniform the a <==> b
  def observe(m1, key1, m2, key2, options={})
    options.to_options!

    # emited signal
    signal = m2.class.obs_calls[key2.to_sym][:signal]
    # reader function to call
    func = "#{key1}=" #m1.class.obs_calls[key1.to_sym][:func]

    controller = options[:controller] || @controller

    #TODO: prep filter chain
    #options[:filter].each do | f |
    #filter_chain_pre = controller.send(f, gen_filter_chain next )

    if options[:fiter].is_a?(Array)
    elsif options[:filter].is_a?(Symbol) or options[:filter].is_a?(String)
      additional_args = options[:args] || []
      m2.connect(signal) do |local_args| 
        args = [local_args]+additional_args
        m1.send(func, controller.send(options[:filter],*args) ) 
      end
      args = [m2.send(key2)]+additional_args
      m1.send( func, controller.send(options[:filter],*args) ) 
    else
      m2.connect(signal, m1, func)
      m1.send(func, m2.send(key2)) 
    end
  end

  module ClassMethods
    attr_accessor :obs_calls

    def observe_attr(*names) #, params = {})
      names.each do |name|
        params = {:signal => "#{name}_changed", :func => "#{name}="} #.merge(params)

        @obs_calls ||= {}
        @obs_calls[name] = if @obs_calls[name]
                             @obs_calls[name].merge(params)
                           else 
                             params
                           end     

        params[:override]=true unless method_defined?(params[:func])        
        alias_method "o_assign_#{name}", params[:func] unless params[:override]

        class_eval %{
          def #{name}_changed
            emit "#{params[:signal]}", self.#{name}
          end
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
    end

  end
end

