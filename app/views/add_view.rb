
window :text=> "gl test", :width => 400, :height => 400 do 

  stack do
    @glw = glarea        
    hslider(:max=>360){ @add.rotation_observe @parent, :value, :filter=> :update, :controller => self}
    button :click => :click
  end
end

