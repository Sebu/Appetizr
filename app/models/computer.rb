

class Computer < ActiveRecord::Base
  require 'ftools'
  include ObserveAttr 
  multi_db

  # non rails conform table :/
  set_table_name "Cache"
  set_primary_key "Cname"
  alias_attribute :user, :User
  alias_attribute :color, :Color
  alias_attribute :time, :Time

  observe_attr :User, :Color
  validates_numericality_of :Color, :greater_than_or_equal_to => 0, :less_than => 8
  after_update :change_vtab
  named_scope :updated_after, lambda { |time| {:conditions => ["Time > ?", time]} }

  before_update do |record|
    record.Color = CONFIG['color_mapping'][ Account.gen_color(record.user.split(" ")) ]
    Debug.log.debug "color change #{record.Cname} #{record.User} color is #{record.Color}"
  end
  
  before_update do |record|
    record.time = Time.now.strftime("%j%H%M%S")
  end

  def user_list
    @user_list = self.user.split(" ")
  end


  def xdm_restart
    `ssh root@s8 -- "ssh #{self.id} -- /etc/init.d/xdm restart"`
  end

  
  def remove_user(u)
    list = self.user.split(" ")
    list.delete(u)
    self.user = list.join(" ")
    #TODO auto generate color
    save
  end
  
 
  def prectab=(value)
    @prectab = value
  end
  
  def prectab
    @prectab ||= nil
  end
  observe_attr :prectab
  
  
  def change_vtab
    filename = "#{CONFIG['validtab_path']}validtab.#{self.Cname}"
    return unless File.exists?(filename)
    last=""
    File.open(filename,"r") do |vtab|
      line = vtab.readline
      Debug.log.debug "before: #{line}"
      one, last = line.split("#")
      allow, first = one.split("=")      
    end
    File.open(filename,"w") do |vtab|
      begin
        vtab.flock(File::LOCK_EX)
        new_line = "ALLOWED= #{self.User} ##{last}" 
        Debug.log.debug "new: #{new_line}"
        vtab.puts new_line
      ensure
        vtab.flock(File::LOCK_UN)
      end
    end
  end


  def self.find_cluster(cluster)
    # old REGEXP '^c?.$'  
    find(:all, :select=>"Cname,Color,User", :conditions=> ["Cname LIKE 'c?_'",cluster], :order => "Cname ASC") 
  end


end

