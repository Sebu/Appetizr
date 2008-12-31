
dialog "gl test", :width => 400, :height => 400 do 
  stack do
    @glw = glarea { update_observe @add, :rotation }

    hslider :max=>360 do
      @add.rotation_observe @parent, :value
    end
  end
end

