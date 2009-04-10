


module Indigo
  module Application

    autoload :Windowed, 'indigo/application_windowed'

    module Base
      ActiveRecord::Base.logger = Debug.log
    end
  end
end

