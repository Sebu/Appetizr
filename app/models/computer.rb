


require 'multiple_databases'
require 'ftools'
require 'signaling'
require 'observe_attr'
require 'active_node'

class Computer < ActiveRecord::Base
  include ActiveNode
  include ObserveAttr 
  multi_db

  set_table_name "Cache"
  set_primary_key "Cname"
  after_update :change_vtab
  obs_attr :User, :override => true
  obs_attr :Color, :override => true
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
