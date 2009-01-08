
require 'active_record'

module Indigo
  module Application

    autoload :Windowed, 'application_windowed'

    module Base

      class << self; attr_accessor :log end
      @log = ActiveSupport::BufferedLogger.new(STDOUT)
      ActiveRecord::Base.logger= @log 

    end
  end
end

