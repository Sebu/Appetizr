

button :id => @c.Cname do
  tool_tip_observe @c, :User
  click :cbutton_click, @c
  background_observe @c, :Color, :filter=> :code_to_color

  drag_start :direct, @c
  drag_delete :key_clear
  drop :drop_users, @c

  stack :margin => 2 do
    label "<b>#{@c.Cname}</b>" , :size => 8
    label(:size => 7) { text_observe @c, :User, :filter=> :user_list_format }
    stretch
  end
end


#TODO: do this somewhere else (in model or controller?? or herlper??)
name @c, "#{@c.Cname}_model"

