

require 'active_record'

module Indigo
  module Application
    module Base

      class << self; attr_accessor :log end
      @log = Logger.new(STDOUT)
      @log.level = Logger::DEBUG
      ActiveRecord::Base.logger= @log 
  
    end
  end
end

