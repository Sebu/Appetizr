
window :text=> "gl test" do 

  stack do
    @glw = glarea        
    hslider(:max=>360){ @add.rotation_observe @parent, :value, :filter=> :update, :controller => self}
    button :click => :click
  end
end

