

class AddController  
  include Indigo::Controller
  
  def after_initialize
    @main = Main.one
  end
  
  def scan_string_format(scan_string)
    "Barcode: #{scan_string}"
  end
  
  def field_return(w)
    users = w.text.split(',').each { |n| n.strip! }
    # TODO: check existance of users
    users.each { |user| Account.create(:barcode=>@main.scan_string, :account=>user) }
  end
  
end

