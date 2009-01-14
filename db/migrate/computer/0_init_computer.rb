
puts "SSD"
class InitComputer < ActiveRecord::Migration
  def self.up
    create_table :Cache, :primary_key => :Cname do |table|
      table.string  :Cname, :null => false, :limit => 4
      table.integer :Color, :null => false, :default => 0
      table.string  :User, :null => false, :limit => 36
      table.integer :Time, :null => false, :default => 0
    end
  end

  def self.down
    drop_table :Cache
  end
end
