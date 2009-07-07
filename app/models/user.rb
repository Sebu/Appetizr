
class User < UserAccountDB
  set_table_name "equiv"
  set_primary_key "alias"
  has_many :accounts, :foreign_key => "barcode", :primary_key=>"canonical"

  def self.find_accounts_by_barcode(barcode)
    find(:first, :conditions => ["alias = ?", barcode]).accounts
  end

end




