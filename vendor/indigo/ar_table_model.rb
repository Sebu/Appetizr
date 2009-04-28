

module Indigo
class ARTableModel < Qt::AbstractTableModel

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

    def rowCount(parent)
        @rows.size
    end

   def columnCount(parent)
        @keys.size
   end


    def data_raw(index)
        item = @rows[index.row]
        return nil if item.nil?
        raise "invalid column #{index.column}" if (index.column < 0 ||
            index.column > @keys.size)
        return item.attributes[@keys[index.column]]
    end

    def data(index, role=Qt::DisplayRole)
        invalid = Qt::Variant.new
        return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
        item = @rows[index.row]
        return invalid if item.nil?
        raise "invalid column #{index.column}" if (index.column < 0 ||
            index.column > @keys.size)
        return Qt::Variant.new(item.attributes[@keys[index.column]])
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
        @readonlys.include?(att) ? super(index) : (Qt::ItemIsEditable|super(index))
    end

    def setData(index, variant, role=Qt::EditRole)
        if index.valid? and role == Qt::EditRole
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
            eval "item.#{att}=value"
            item.save
            emit dataChanged(index, index)
            return true
        else
            return false
        end
    end
    
#    def setData(index, variant, role=Qt::EditRole)
#        if index.valid? and role == Qt::EditRole
#            item = @rows[index.row]
#            values = item.attributes
#            puts item[@keys[index.column]]
#            att = @keys[index.column]
#            raise "invalid column #{index.column}" if (index.column < 0 ||
#                index.column > @keys.size)
#            values[att] = case item.attributes[att].class.name
#            when "String"
#                variant.toString
#            when "Fixnum"
#                variant.toInt
#            when "Float"
#                variant.toDouble
#            else
#                variant.value
#            end
#            p item, values
#            item.attributes=values
#            item.save
#            emit dataChanged(index, index)
#            return true
#        else
#            return false
#        end
#    end
end
end
