
require 'active_record'

module Indigo
  module Application
    module Base

      class << self; attr_accessor :log end
      @log = ActiveSupport::BufferedLogger.new(STDOUT)
      ActiveRecord::Base.logger= @log 
  
    end
  end
end

