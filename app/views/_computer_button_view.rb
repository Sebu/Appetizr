

button :id => @c.Cname, :height => 60 do
  tool_tip_observe @c, :User
  click :cbutton_click, @c
  background_observe @c, :Color, :filter=> :code_to_color

  drag_start :direct, @c
  drag_delete :key_clear
  drop :drop_users, @c

  menu "context" do
    action "nothing", :nothing
    separator
    menu "hardcore" do
      action "xdm restart", :restart, @c
    end
  end

  stack :margin => 2 do
    flow do
    label "<b>#{@c.Cname}</b>" , :size => 8
    stretch
    label(:size => 8) { text_observe @c, :prectab, :filter=> :prectab_format }

    end
    label(:size => 7) { text_observe @c, :User, :filter=> :user_list_format }
    stretch
  end
end
