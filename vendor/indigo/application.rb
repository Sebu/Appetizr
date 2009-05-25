


module Indigo
  module Application
    def self.run
      app = SomeGui::Application.new(ARGV)
      Controller.redirect_to "/#{CONFIG["controller"].to_s}s/1"
      app.main_loop
    end
  end
end

