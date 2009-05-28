

class AccountList < Indigo::ObjectListStore

  #lists/presents/has_many :accounts
  column :account, String #, true
  column :barcode, String
  column :locked, TrueClass
  after_edit :save

end

