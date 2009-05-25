

class Indigo::ARListStore < Gtk::ListStore

  attr_accessor :columns, :keys, :types
  
  def initialize(records, col_names=[])
    return if records.empty?
    @columns = records
    @keys = col_names
    @types = @keys.collect { |name| columns.first[name].class }
    super(*@types)
    columns.each do |record|
      child = append
      keys.each_with_index { |k,i| child[i] = record[k] }
    end
  end


  def set_value(path,col, value)
    item = columns[path.to_s.to_i]
    eval "item.#{keys[col]}=value"
    item.save
    get_iter(path).set_value(col, item[keys[col]] )
  end
    
  def get_value(path,col)
    columns[path.to_s.to_i][keys[col]]
  end

  def raw_data(path)
    columns[path.to_s.to_i]
  end


end


