

class AddController  
  include Indigo::Controller
  
  def after_initialize
    @main = Main.active
  end
  
  def scan_string_format(scan_string)
    "Nr.: #{scan_string}"
  end
  
  def register_user
    users = Add.active.account_field.text.split(',').each { |n| n.strip! }
    # TODO: check existance of users
    users.each { |user| Account.create!(:barcode=>Main.active.scan_string, :account=>user) }
    close
  end
  
end

