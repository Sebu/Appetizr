

class AddController < Indigo::Controller
  helper MainHelper
    
  def show
    @main = Main.active
    @add = Add.active
    render.show_all
  end
  
  def register_user
    users = Add.active.account_field.text.split(',').each { |n| n.strip! }
    users.each { |user| Account.create!(:barcode=>Main.active.scan_string, :account=>user) }
    close
  end
  
end

