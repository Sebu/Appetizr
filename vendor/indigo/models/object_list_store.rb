
# list object list attributes in a Gtk::TreeView
#
#
# list = ObjectListStore.new(String,String)
# list.add_objects([["foo","bar"]])
# list.add_object(["foo","bar"])
#
# ObjectListStore.new( [["foo","bar"]] )
#
# ObjectListStore.new( [{:foo=>:bar}] )
#
#   @account_list = Indigo::ObjectListStore.new(String, String, TrueClass, :columns=>[:account, :barcode, :locked], :after_edit=>:save)
#
# define after_edit :method
# to call :method after edit occured

class Indigo::ObjectListStore < Gtk::ListStore

  attr_accessor :columns, :keys, :types
  @keys = nil
  @types = nil
  @after_edit_method = nil
    
  def self.keys
    @keys
  end  
  
  def self.types
    @types
  end  

  def self.keys=(value)
    @keys = value
  end  

  def self.types=(value)
    @types = value
  end  


  def self.after_edit(method)
    @after_edit_method = method
  end
  
  def self.after_edit_method
    @after_edit_method
  end
  
  def self.column(key, type)
    @keys ||= []
    @types ||= []
    keys << key
    types << type
  end
  
  def initialize(*args)
    options = args.extract_options!
    options.to_options!
    @exclude = options[:exclude] || []
    @include = options[:columns] || []
    @after_edit = self.class.after_edit_method || options[:after_edit]
    @types ||= self.class.types
    @types ||=  extract_constants(args)
    records = extract_data(args)
    @types ||=  extract_types(records)
    super(*@types)
    @columns = []
    
    add_objects(records)
  end

  def extract_types(records)
    return nil unless records
    records.first.collect{ |record| record.class }
  end
  
  def extract_constants(args)
     constants = args.select { |arg| arg.is_a?(Class) }
     constants.empty? ? nil : constants
  end

  def extract_keys(record)
    keys = if record.is_a?(Array)
      [:first,:second,:third].to(record.size-1)
    elsif record.is_a?(Hash)
      record.keys
    else
      []
    end
    self.class.keys || (keys | @include) - @exclude
  end

  
  def extract_data(args)
    args.each { |arg| return arg if arg.is_a?(Array) }
    return nil
  end
    
  def add_objects(records)
    return if !records or records.empty?
    @keys ||=  extract_keys(records.first)
    @columns.concat(records)
    columns.each do |record|
      child = prepend
      keys.each_with_index { |k,i| child[i] = record.send(k) }
    end
  end
  
  def add_object(record)
    return unless record
    @keys ||= extract_keys(record)
    @columns << record
    child = prepend
    keys.each_with_index { |k,i|  child[i] = record.send(k) }
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
    item.send("#{keys[col]}=",value)
    item.send(@after_edit) if @after_edit
    get_iter(path).set_value(col, item.send(keys[col]) ) 
  end
    
  def get_value(path,col)
    columns[path.to_s.to_i].send(keys[col])
  end

  def [](path)
    columns[path.to_s.to_i]
  end


end


