

require 'qtext/flags'
module Indigo
class ARTableModel < Qt::AbstractTableModel
  include QtFlags
  
  attr_reader :rows

    
    def initialize(rows,columns=nil)
        super()
        @rows = rows
        @readonlys = rows.first ? rows.first.class.readonly_attributes : Set.new
        if columns
            if columns.kind_of? Hash
                @keys=columns.keys
                @labels=columns.values
            else
                @keys=columns
            end
        else
            @keys=@rows.first.attributes.keys
        end
        @labels||=@keys.collect { |k| k.humanize }
    end

    def index(row,col,parent=nil)
      createIndex(row,col)
    end
    
    def rowCount(parent=nil)
        @rows.size
    end

   def columnCount(parent=nil)
        @keys.size
   end


    def data_raw(index)
        item = @rows[index.row]
        return nil if item.nil?
        raise "invalid column #{index.column}" if (index.column < 0 ||
            index.column > @keys.size)
        return item #.attributes #[@keys[index.column]]
    end

    def data(index, role=Qt::DisplayRole)
        raise "invalid column #{index.column}" if (index.column < 0 ||
            index.column > @keys.size)
        invalid = Qt::Variant.new
        item = @rows[index.row]
        date = item.attributes[@keys[index.column]]
        is_bool = [TrueClass,FalseClass].any? {|x| x === date }
        return invalid if item.nil?
        return Qt::Variant.new((date ? qt_checked : qt_unchecked).to_variant ) if role == Qt::CheckStateRole and is_bool
        return invalid if is_bool
        return invalid unless role == Qt::DisplayRole or role == Qt::EditRole 
        return Qt::Variant.new(date)
    end

    def headerData(section, orientation, role=Qt::DisplayRole)
        invalid = Qt::Variant.new
        return invalid unless role == Qt::DisplayRole

        v = case orientation
        when Qt::Horizontal
            @labels[section]
        else
            ""
        end
        return Qt::Variant.new(v)
    end

    def flags(index)
        att = @keys[index.column]
        @readonlys and @readonlys.include?(att) ? super(index) : (Qt::ItemIsUserCheckable|super(index))
    end

    def setData(index, variant, role=Qt::EditRole)
        if index.valid? and role == Qt::EditRole or role == Qt::CheckStateRole
            raise "invalid column #{index.column}" if (index.column < 0 ||
                index.column > @keys.size)
            item = @rows[index.row]
            att = @keys[index.column]
            value = case item.class.name
            when "String"
                variant.toString
            when "Fixnum"
                variant.toInt
            when "Float"
                variant.toDouble
            else
                variant.value
            end
            value = ( value == qt_checked ? true: false) if role == Qt::CheckStateRole
            eval "item.#{att}=value"
            item.save
            emit dataChanged(index, index)
            return true
        else
          return false
        end
    end
    
end
end
