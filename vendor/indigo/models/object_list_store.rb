
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

  include ActiveSupport::Callbacks
  define_callbacks :before_remove, :before_edit
    
  attr_accessor :keys, :types, :editable, :item
  @keys = nil
  @types = nil
  @editable = nil 
    
  def self.keys
    @keys
  end  
  
  def self.types
    @types
  end  

  def self.editable
    @editable
  end  


  def self.column(key, type, edit=false)
    @keys ||= []
    @types ||= []
    @editable ||= []
    keys << key
    types << type
    editable << edit
  end
  
  def initialize(*args)
    @columns = 0
    options = args.extract_options!
    options.to_options!
    @exclude = options[:exclude] || []
    @include = options[:columns] || []
    records = extract_data(args)
    @types = self.class.types || extract_constants(args) || extract_types(records)
    puts @types
    @editable = self.class.editable || [false]*(@types.size+1)
    super(*([Object]+@types))
    add_all(records)
  end

  def extract_types(records)
    return nil unless records
    record = records.first
    case record
    when Array
      records.first.collect{ |record| record.class }
    else
      [record.class]
    end
  end
  
  def extract_constants(args)
     constants = args.select { |arg| arg.is_a?(Class) }
     constants.empty? ? nil : constants
  end

  def extract_keys(record)
    keys = if record.is_a?(Array)
      [:first,:second,:third,:fourth,:fifth].to(record.size-1)
    elsif record.is_a?(Hash)
      record.keys
    else
      ["to_s"]
    end
    self.class.keys || (keys | @include) - @exclude
  end

  
  def extract_data(args)
    args.each { |arg| return arg if arg.is_a?(Array) }
    return nil
  end
    
  def add_all(records)
    return if !records or records.empty?
    @keys ||=  extract_keys(records.first)
    records.each do |record|
      child = append
      child[0] = record
      keys.each_with_index { |k,i| child[i+1] = record.send(k) }
      @columns += 1
    end
  end
  
  def add(record, parent=nil)
    return unless record
    @keys ||= extract_keys(record)
    child = append
    child[0] = record
    keys.each_with_index { |k,i|  child[i+1] = record.send(k) }
    @columns += 1
    child
  end

  def empty?
    puts @columns
    @columns == 0
  end
  
  def clear 
    @columns = 0 
    super
  end

  def remove(iter)
    @columns -= 1
    @item = iter.get_value(0) 
    super if run_callbacks(:before_remove)
  end
  
  def set_value(path,col, value)
    @item = get_iter(path).get_value(0) 
    item.send("#{keys[col-1]}=",value)
    get_iter(path).set_value(col, item.send(keys[col-1]) ) if run_callbacks(:before_edit)

    
  end
    
  def get_value(path, col)
    get_iter(path).get_value(0).send(keys[col-1])
  end

  def [](path)
    get_iter(path).get_value(0)
  end


end


