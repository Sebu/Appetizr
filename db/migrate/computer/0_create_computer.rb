
class CreateComputer < ActiveRecord::Migration
  def self.up
#    create_table :Cache, :id=> false, :primary_key => :Cname do |table|
#      table.string  :Cname, :null => false, :limit => 4
#      table.integer :Color, :null => false, :default => 0
#      table.string  :User, :null => false, :limit => 36
#      table.integer :Time, :null => false, :default => 0
#    end
    1.upto(18).each do |pre|
      1.upto(4).each do |post|
        pc = Computer.new
        pc.Cname ="c#{pre}#{post}"
        pc.Color = 0
        pc.User = ""
        pc.Time = 0
        pc.save!
      end
    end
  end

  def self.down
    drop_table :Cache
  end

end
