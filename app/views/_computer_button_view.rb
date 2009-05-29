

button :id => @c.id, :height => 60, :width=> 60 do |button|
  tool_tip_observe @c, :User do |user| user_list_format(user) end
  background_observe @c, :Color, :args=>[@c] do |user,computer| code_to_color(user,computer) end

  drag @c
  drag_delete :key_clear, @c 
  drop :drop_user, @c

  click :table_register, @c

  menu :context do
    action :cancel, "/nothing"
    separator
    menu "hardcore" do
      action "xdm restart", "/computers/restart/#{@c.id}" #, @c
    end
  end

  flow do
    label "<span size='small'><b>#{@c.id}</b></span>" , :size => 8
    stretch
    label(:size => 8) {
      text_observe @c, :prectab do |prectab| prectab_format(prectab) end
    }
  end
  label(:size => 7) { 
    text_observe @c, :User do |user| user_list_format(user) end 
  }
  
end
