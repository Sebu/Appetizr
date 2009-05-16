
require 'ftools'

class Computer < ActiveRecord::Base
  include Indigo::ActiveNode
  include ObserveAttr 
  multi_db

  set_table_name "Cache"
  set_primary_key "Cname"

  observe_attr :User, :Color
  
  validates_numericality_of :Color, :greater_than_or_equal_to => 0, :less_than => 8
  after_update :change_vtab

  def xdm_restart
    `ssh -f root@s8 -- "ssh {self.Cname} -- /etc/init.d/xdm restart"`
  end

  def after_reload
    self.Color_changed
    self.User_changed
  end

  def prectab=(value)
    @prectab = value
  end
  
  def prectab
    @prectab ||= nil
  end
  observe_attr :prectab
  
  
  def change_vtab
    filename = "#{CONFIG['VALIDTAB_PATH']}validtab.#{self.Cname}"
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

