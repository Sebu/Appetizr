

class ComputerController < Indigo::Controller
  
  def restart
    @pc = Computer.find(params[:id])
    @pc.xdm_restart if confirm "Wirklich xdm auf #{params[:id]} mit user: #{@pc.user} neu starten?"
  end

=begin  
  def cbutton_click
    @pc = Computer.find(params[:id])
    if Main.active.account_table.model
      table_register(@pc)
    end
  end
=end
  
end
