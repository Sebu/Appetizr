
class Account < UserAccountDB
  include ObserveAttr

  set_table_name "map"
  belongs_to :user

  attr_readonly :barcode, :account
  attr_accessible :account, :locked, :barcode

  validates_presence_of :barcode
  validates_length_of :account, :maximum=>30
  
  named_scope :find_accounts_by_barcode, lambda { |barcode| {:group => "account", :conditions => ["barcode = ?", barcode]} }
  named_scope :find_accounts, lambda { |users| { :conditions => ["barcode IN (?) OR account IN (?)", users, users], :group => "account" } }


  def self.find_accounts_or_initialize(users)
    accounts = self.find(:all, :conditions => ["barcode IN (?) OR account IN (?)", users, users], :group => "account" )
    accounts.each do |account| 
      users.delete(account.account) if users.include?(account.account)
    end if accounts
    accounts ||= []
    users.each do |user|
       accounts << Account.new do |account| 
                                 account.account = user 
                                 account.barcode = nil       
                               end
    end if users
    accounts
  end

  #TODO: workaround ( for our non rails conform tables ) 
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

 
  def is_private?
    not /.{3}-[0-9a-f]{3}$/ === account 
  end
  
  def locked=(value)
    system("#{CONFIG['admin_sh_file']} -unlock #{self.account}") if self[:locked] == true and value == false
    self[:locked] = false
  end

  def locked
    self[:locked] 
  end

  def after_initialize
   self[:locked] ||= get_lock_state(self.account)
  end

  def self.get_passwd(user)
    system("#{CONFIG['pw_check_file']} #{user}")
    case $?
      when 0:   return :ok
      when 256: return :no_passwd
      when 512: return :locked
      when 768: return :is_no_user
      #else raise "password check failed - returned #{$?}"
    end    
  end

  
  def self.gen_color(users)
    users.each do |user|
      case user
      when "jeder": return :jeder
      when "nobody": return :nobody
      else
        return :normal if INDIGO_ENV == "development"
        case `getgroup -stat "#{user}"`.chomp!
        when "excoll","wheel": return :wheel
        when "assi","tutor": return :tutor
        else 
          case Account.get_passwd(user)
          when :locked:    return :locked
          when :no_passwd: return :no_passwd
          else return :normal
          end
        end                  
      end
    end                    
  end 
  
  def get_lock_state(user)
    case Account.get_passwd(user)
    when :ok:         return false
#   when :is_no_user: return :no_user
    else              return true
    end
  end

end

