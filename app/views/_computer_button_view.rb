

button :id => @c.id, :height => 60, :width=> 60 do #, :click=> "/computers/cbutton_click/#{@c.id}" do
  tool_tip_observe @c, :User

  #click "/computers/cbutton_click/#{@c.id}"
  click :cbutton_click, @c

  #background_observe "/computer/#{@c.Cname}/Color", :filter=> :code_to_color
  background_observe @c, :Color, :filter=> :code_to_color, :args=>[@c]

  drag :direct, @c # drag @c 
  drag_delete :key_clear, @c # "/#{@c.id}/key_clear/"
  drop :drop_user, @c

  menu :context do
    action "nothing", "/nothing"
    separator
    menu "hardcore" do
      action "xdm restart", "/computers/restart/#{@c.id}" #, @c
    end
  end

  stack :margin => 2 do
    flow do
      label "<b>#{@c.id}</b>" , :size => 8
      stretch
      label(:size => 8) { text_observe @c, :prectab, :filter=> :prectab_format }
    end
    label(:size => 7) { text_observe @c, :User, :filter=> :user_list_format }
    stretch
  end
end
