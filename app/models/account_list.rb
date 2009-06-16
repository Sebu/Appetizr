require 'gtk2'

class AccountList < Indigo::ObjectListStore

  #lists/presents/has_many :accounts
  column :account, String
  column :locked, TrueClass, true
  column :color, Gdk::Pixbuf

  # TODO create own callbacks with list item rather then list
  before_remove do |list|
    Account.delete_all("barcode='#{list.item.barcode}' AND account='#{list.item.account}'") 
  end
  
#  before_edit do |list|
#    list.item.save
#  end
  
end

