
require 'useraccountdb'
require 'account_helper'

class Account < UserAccountDB
  include ObserveAttr 

  set_table_name "map"
  set_primary_key "barcode"
  belongs_to :user

  attr_readonly :barcode
  attr_accessible :account, :locked

#  named_scope :accounts_by_barcode, lambda { |barcode| {:group => "account", :conditions => ["barcode = ?", barcode]} }
#  named_scope :check_accounts, lambda { |users| { :conditions => ["barcode IN (?) OR account IN (?)", users, users], :group => "account" } }


  def self.find_accounts_by_barcode(barcode)
    #accounts_by_barcode barcode
    find(:all, :group => "account", :conditions => ["barcode = ?", barcode])
  end

  def self.find_accounts(users)
    #check_accounts users
    find(:all, :group => "account", :conditions => ["barcode IN (?) OR account IN (?)", users, users])
  end



  def update(attribute_names = @attributes.keys)
        quoted_attributes = attributes_with_quotes(false, false, attribute_names)
        return 0 if quoted_attributes.empty?
        connection.update(
          "UPDATE #{self.class.quoted_table_name} " +
          "SET #{quoted_comma_pair_list(connection, quoted_attributes)} " +
          "WHERE #{connection.quote_column_name(self.class.primary_key)} = #{quote_value(id)} AND account=#{quote_value(self.account_was)}",
          "#{self.class.name} Update"
        )
  end

  def locked=(value)
    self[:locked] = value
    #set lock state
  end

  def locked
    #get lock state?
    self[:locked] 
  end

  def after_initialize
   self.locked ||= get_lockstate(self.account)
  end

end

