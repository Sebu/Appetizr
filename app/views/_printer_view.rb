
box {
  background_observe @printer, :enabled do |state| color_please(state) end

  expander { |exp|
    background_observe @printer, :enabled do |state| color_please(state) end

    printer = @printer #TODO fix
    on :click do  update_printer_menu(printer); false end
    menu :id=>"#{@printer.name}_menu"

    
    ignore_next #TODO remove need for it
    exp.label_widget = flow(:width=>120) {
      tool_tip_observe @printer, :display
      box {
        background_observe @printer, :accepts do |state| color_please(state) end
        label "#{@printer.name}" 
      }
      box(:width=>100) {
        background_observe @printer, :enabled do |state| color_please(state) end
        label { markup_observe @printer, :job_count }
      }
    }

    box {|b|
      b.background="#FFFFFF"
      label { markup_observe @printer, :display }
    }
  }
}
