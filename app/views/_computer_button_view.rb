

button :id => @computer.id, :height => 60, :width=> 60 do 
  computer = @computer
# tool_tip_observe @computer, :User do |user| user_list_format(user) end
  background_observe @computer, :Color, :args=>[@computer] do |color, computer| code_to_color(color,computer) end

  drag @computer
  drag_delete :key_clear, @computer 
  drop :drop_user, @computer

  on :click, :table_register, computer

  menu :context, :id=> "button_menu" do
    computer = @computer #TODO: remove need for locality
    @computer.on_user_changed do |user| gen_button_menu(user, computer) end
    # better
    # @computer.changed? do |computer| gen_blabla_ end
  end

  flow do
    label "<span size='small'><b>#{@computer.id}</b></span>" , :size => 8
    label(:size => 8) {
      markup_observe @computer, :prectab do |prectab| prectab_format(prectab) end
    }
  end
  label(:size => 7) { 
    markup_observe @computer, :User, :args=>[@computer] do |user,computer| user_list_format(computer) end 
  }
end
