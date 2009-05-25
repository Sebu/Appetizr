

class AccountList < Indigo::ObjectListStore

  
  #lists/presents/has_many :accounts
  column :account, String #, true
  column :locked, TrueClass
  column :barcode, String
  after_edit :save
 

end

