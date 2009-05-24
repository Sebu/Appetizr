


module Indigo
  module Application

    module Base
      ActiveRecord::Base.logger = Debug.log
    end

    module Windowed
      def run
        app = SomeGui::Application.new(ARGV)
        Controller.redirect_to "/#{CONFIG["controller"].to_s}s/1"
        app.main_loop
      end
    end
    
  end
end

