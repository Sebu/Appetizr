
class CreateAdm < ActiveRecord::Migration
  def self.up
#    create_table :map, :id => false do |table|
#      table.string :barcode, :limit => 32
#      table.string :account, :limit => 8
#    end
#    create_table :equiv, :primary_key => :alias do |table|
#      table.string :alias, :limit => 32
#      table.string :canonical, :limit => 32
#    end
    acc = Account.new
    acc.account = "alg-123"
    acc.barcode = "1111"
    acc.save!
    acc = Account.new
    acc.account = "co1-200"
    acc.barcode = "1234"
    acc.save!
  end

  def self.down
    drop_table :map
    drop_table :equiv
  end
end
