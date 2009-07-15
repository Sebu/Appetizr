
module MainHelper

  def scan_string_format(scan_string)
    "Nr.: #{scan_string}"
  end
  
  def user_list_format(computer)
    return if computer.user.empty? and !computer.prectab
    return "<span color='#7A7A70'>#{computer.prectab[1]}</span>" if computer.user.empty?
    names = computer.user_list[0,3].join("\n")
    "<span size='x-small'>#{names}</span>"
  end

  def prectab_format(prectab)
    return unless prectab
    "<b><span size='x-small' color='#FEFEAA'>#{prectab[0]}</span></b>" 
  end
  
  
  def color_please(value)
    value ? "#82c927" : "#fe2f2f"
  end


  def code_to_color(code, computer)
    if computer.prectab and (computer.prectab[0] or computer.prectab[1]) and computer.user == ""
      CONFIG['colors'][8]
    else
      CONFIG['colors'][computer.color]
    end
  end


  def update_notifies_menu(data)
    update "notifies_menu" do
      cleanup
      data.notifies.each do |notify|
        menu "#{notify.body}" do
          action "modify" do notify.body=input(notify.body); notify.save; @main.account_list.update end
          action "remove" do notify.delete if confirm; @main.account_list.update end
        end
      end
      action "add notify"
    end  
  end
    
  def update_printer_menu(printer)
    update "#{printer.name}_menu" do
      cleanup
      jobs = printer.jobs
      action "leer" if jobs.empty?
      jobs.each { |job|
        menu "#{job.time} | #{job.id} | #{job.user} | #{job.size}" do
          action "cancel" do job.cancel if confirm("Wirklich job: #{job.id} von #{job.user} abbrechen?") end
          Printer.printers.each { |other|
            action "move to #{other.name}" do job.move_to(other.name) if confirm("Wirklich job: #{job.id} von #{job.user} auf #{other.name} verschieben?") end
          }
        end
      }
    end  
  end

  def gen_button_menu(user, computer)
    render :update => berry[computer.id].berry["button_menu"] do
      cleanup
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
