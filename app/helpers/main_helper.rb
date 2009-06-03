
module MainHelper
  def user_list_format(a)
    return if a.empty?
    "<span size='x-small'>#{a.tr(" ","\n")}</span>"
  end

  def prectab_format(prectab)
    "<b><span size='x-small' color='#FEFEAA'>#{prectab}</span></b>" 
  end
  
  
  def color_please(value)
    value ? "#82c927" : "#FFFFAA"
  end


  def code_to_color(code, computer)
    if computer.prectab and computer.user == ""
      CONFIG['colors'][8]
    else
      CONFIG['colors'][computer.color]
    end
  end
  
  def gen_printer_menu(printer)
    render :update => berry["#{printer.name}_menu"] do
      jobs = printer.jobs
      action "leer" if jobs.empty?
      jobs.each { |job|
        menu "#{job.id}| #{job.user}| #{job.size}" do
          action "cancel" do job.cancel end
          Indigo::Printer.printers.each { |other|
            action "move to #{other.name}" do job.move_to(other.name) end
          }
        end
      }
    end  
  end

  def gen_button_menu(user, computer)
    render :update => berry[computer.id].berry["button_menu"] do
      user.split(" ").each do |user|
        menu user.to_s do
          action :remove  , :remove_from_pc, computer, user
        end
      end
      separator
      menu "hardcore" do
        action "xdm restart", "/computers/restart/#{computer.id}"
      end
    end  
  end   
  
end
