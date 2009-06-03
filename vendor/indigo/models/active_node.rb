

module Indigo
  module ActiveNode
    include Signaling
    
    #attr :bla, String, :length bla bla

    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      def active
        @active ||= self.new
      end
    end
    
  end
end

