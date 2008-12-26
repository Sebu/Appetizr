

button :id => @c.Cname do
  click :cbutton_click, @c
  background_observe @c, :Color, :filter=> :code_to_color

  drag_start :drag_users, @c
  drag_delete :key_clear
  drop :drop_users, @c

  stack :margin => 2 do
    label :text => "<b>#{@c.Cname}</b>" , :size => 8
    label(:size => 7){ text_observe @c, :User, :filter=> :user_list_format }
    #svg :file=> "test.svg"
    stretch
  end
end


#TODO: do this somewhere else (in model or controller??)
name @c, "#{@c.Cname}_model"

