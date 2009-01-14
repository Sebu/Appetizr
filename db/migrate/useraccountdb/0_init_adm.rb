
class InitAdm < ActiveRecord::Migration
  def self.up
    create_table :map, :id => false do |table|
      table.string :barcode, :limit => 32
      table.string :account, :limit => 8
    end
    create_table :equiv, :primary_key => :alias do |table|
      table.string :alias, :limit => 32
      table.string :canonical, :limit => 32
    end
  end

  def self.down
    drop_table :map
    drop_table :equiv
  end
end
