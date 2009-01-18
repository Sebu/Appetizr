
require 'ftools'

class Computer < ActiveRecord::Base
  include Indigo::ActiveNode
  include ObserveAttr 
  multi_db

  set_table_name "Cache"
  set_primary_key "Cname"
  after_update :change_vtab
  obsattr_writer :User, :override => true
  obsattr_writer :Color, :override => true
  validates_numericality_of :Color, :greater_than_or_equal_to => 0, :less_than => 6

  def change_vtab
    filename = "#{CONFIG['VALIDTAB_PATH']}#{CONFIG['VALIDTAB_FILE_PREFIX']}#{self.Cname}"
    return unless File.exists?(filename)
    vtab = File.new(filename,"r+")
    begin
      vtab.flock(File::LOCK_EX)
      line = vtab.readline
      one, last = line.split("#")
      allow, first = one.split("=")
      vtab.pos = 0
      new_line = "#{allow}= #{self.User} ##{last}" 
      vtab.print new_line
    rescue EOFError
      vtab.flock(File::LOCK_UN)
      vtab.close
    else
      vtab.flock(File::LOCK_UN)
      vtab.close
    end
  end


  def self.find_cluster(cluster)
    # old REGEXP '^c?.$'  
    find(:all, :select=>"Cname,Color,User", :conditions=> ["Cname LIKE 'c?_'",cluster], :order => "Cname ASC") 
  end
end
