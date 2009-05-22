


module Indigo
  module Application
    module Windowed

      def run
        require 'Qt4'

        the_app = SomeGui::Application.new(ARGV)
        Controller.redirect_to "/#{CONFIG["controller"].to_s}s/1"
        the_app.main_loop
      end

    end
  end
end







