
dialog "gl test", :width => 400, :height => 400 do
  stack do
    @glw = glarea do
      update_observe @add, :rotation
      dialog "gl test" ,:width => 400, :height => 400 do
        stack do
          hslider :max=>360 do
            @add.rotation_observe @parent, :value
          end

          button "undo", :click => :undo
          button "gl demo", :click => :click_gl_demo
          button("open files") { click :open_action, :files }

          @slider = hslider :min=> -100
          @spin = spin { value_observe @slider, :value }
          @slider.value_observe  @spin, :value     
          radio "test2"
          check "test3"
          stretch
        end
      end
    end
    hslider :max=>360 do
      @add.rotation_observe @parent, :value
    end
  end
end

