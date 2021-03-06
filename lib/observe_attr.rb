  

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


  def method_missing(name, *args, &block)
    match = /_observe/.match(name.to_s)
    if match
      setter = match.pre_match.to_sym
      if args[0].is_a?(String)
        #disassamble args[0] /model/id/attribute'
        #model.send(observe_attr_after_initialize, :key=>id, :attr=>attribute)        
        # '/computer/c12/Color'
        # Computer.send( observe_after_initialize, :receiver=>self, :setter=>setter, :key=>id, :attr=> 'Color')
        # after_initialize
        #   if id == key
        #     instance_eval ...
        #     observe(options[:receiver], options[:setter], self, options[:attr])
        #   end
        # end
      else
        observe(self, setter, *args, &block)
      end
    else
      #Debug.log.debug "  \e[1;31mObserveAttr is missing\e[0m #{name} in #{self}"
      super
    end
  end

  #  TODO: change syntax and uniform the a <==> b
  def observe(m1, key1, m2, key2, options={}, &block)
    options.to_options!

    # emited signal
    signal = "#{key2}_changed"
    # reader function to call
    func = "#{key1}="
    additional_args = options[:args] || []
    
    if block_given?
      m2.connect(signal) { |local_args| 
        args = [local_args]+additional_args
        m1.send(func, block.call(*args) ) 
      }
    else
      m2.connect(signal, m1, func)
    end
    m2.emit(signal, m2.send(key2))
  end

  module ClassMethods

    def observe_attr(*names) #, params = {})
      names.each do |name|
   
        func = "#{name}="
        signal = "#{name}_changed"
        @override = !method_defined?(func)        
        alias_method "o_assign_#{name}", func unless @override

        class_eval %{
          def on_#{name.to_s.downcase}_changed(*args,&block)
            connect("#{signal}", *args, &block)
          end
          
          def #{name.to_s.downcase}_changed
            emit "#{signal}", self.#{name}
          end
          if not @override
            def #{func}(value)
              send("o_assign_#{name}", value)
              emit "#{signal}", value
            end
          else
            def #{func}(value)
              super
              emit "#{signal}", value
            end
          end
        }
      end
    end

  end
end

