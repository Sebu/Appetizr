
require 'signaling'
require 'observe_attr'

module Indigo
  module ActiveNode
    include Signaling

    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      def one
        @one ||= self.new
      end
    end
    
  end
end

