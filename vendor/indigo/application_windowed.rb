


module Indigo
  module Application
    module Windowed

      def run
        the_app = SomeGui::Application.new(ARGV)
        
        name = CONFIG["controller"].to_s
        Controller.redirect_to "/#{name}s/1"

        the_app.main_loop
      end

    end
  end
end








