
# list object list attributes in a Gtk::TreeView
#
# define after_edit :method
# to call :method after edit occured

class Indigo::ObjectListStore < Gtk::ListStore

  attr_accessor :columns
  
  def self.after_edit(method)
    @@after_edit = method
  end
   
  def self.keys
    @@keys ||= []
  end

  def self.types
    @@types ||= []
  end
  
  def self.column(key, type)
    keys << key
    types << type
  end
  
  def initialize(records=[])
    @@after_edit ||= nil
    super(*@@types)
    add_objects(records)
  end
  
  def add_objects(records)
    @columns = records
    return if records.empty?
    columns.each do |record|
      child = append
      @@keys.each_with_index { |k,i| child[i] = record.send(k) }
    end
  end
  
  def empty?
    @columns.empty?
  end
  
  
  def clear
    @columns.clear
    super
  end

  def set_value(path,col, value)
    item = columns[path.to_s.to_i]
    item.send("#{@@keys[col]}=",value)
    item.send(@@after_edit) if @@after_edit
    get_iter(path).set_value(col, item[@@keys[col]] ) 
  end
    
  def get_value(path,col)
    columns[path.to_s.to_i][@@keys[col]]
  end

  def [](path)
    columns[path.to_s.to_i]
  end


end


