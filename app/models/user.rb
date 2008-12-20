
require 'useraccountdb'


class User < UserAccountDB
  set_table_name "equiv"
  set_primary_key "canonical"
  has_many :accounts, :foreign_key => "barcode"

  def self.find_accounts_by_barcodes(barcodes)
    res = find(:first, :conditions => ["canonical IN (?)", barcodes])
    res.accounts
  end

end




