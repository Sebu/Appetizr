
# list object list attributes in a Gtk::TreeView
#
# define after_edit :method
# to call :method after edit occured

class Indigo::ObjectListStore < Gtk::ListStore

  attr_accessor :columns
  
  
  
  def self.keys
    @keys ||= []
  end  
  
  def self.types
    @types ||= []
  end  

  def self.after_edit(method)
    @after_edit = method
  end
  
  def self.column(key, type)
    keys << key
    types << type
  end
  
  def initialize(records=[])
    super(*self.class.types)
    add_objects(records)
  end
  
  def add_objects(records)
    @columns = records
    return if records.empty?
    columns.each do |record|
      child = append
      self.class.keys.each_with_index { |k,i| child[i] = record.send(k) }
    end
  end
  
  def add_object(record)
    return unless record
    @columns << record
    child = append
    self.class.keys.each_with_index { |k,i|  child[i] = record.send(k) }
  end

  def last
    @columns.last
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
    item.send("#{self.class.keys[col]}=",value)
    #item.send(Indigo::ObjectListStore.after_edit) if Indigo::ObjectListStore.after_edit
    get_iter(path).set_value(col, item.send(self.class.keys[col]) ) 
  end
    
  def get_value(path,col)
    columns[path.to_s.to_i].send(self.class.keys[col])
  end

  def [](path)
    columns[path.to_s.to_i]
  end


end


