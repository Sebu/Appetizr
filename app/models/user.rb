
class User < UserAccountDB
  set_table_name "equiv"
  set_primary_key "canonical"
  has_many :accounts, :foreign_key => "barcode"

  def self.find_accounts_by_barcode(barcode)
    res = find(:first, :conditions => ["canonical = (?)", barcode])
    puts res
    res.accounts
  end

end




