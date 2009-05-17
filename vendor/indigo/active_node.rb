

module Indigo
  module ActiveNode
    include Signaling

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

