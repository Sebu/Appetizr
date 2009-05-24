

#require 'Qt4'
#require 'date'

require 'qtext/flags.rb'
require 'qtext/extensions.rb'

#require 'clevic/extensions.rb'
#require 'clevic/model_column'

#begin Indigo
=begin rdoc
This table model allows an ActiveRecord or ActiveResource to be used as a
basis for a Qt::AbstractTableModel for viewing in a Qt::TableView.

* labels are the headings in the table view

* dots are the dotted attribute paths that specify how to get values from
  the underlying ActiveRecord model

* attribute_paths is a collection of attribute symbols. It comes from
  dots, and is split on /\./

* attributes are the first-level of the dots

* collection is the set of ActiveRecord model objects (also called entities)
=end
class TableModel < Qt::AbstractTableModel
  include QtFlags
  
  # the CacheTable of Clevic::Record or ActiveRecord::Base objects
  attr_reader :collection
  
  # the actual class for the collection objects
  attr_accessor :model_class
  
  # the collection of Clevic::Field objects
  attr_reader :fields
  
  attr_accessor :read_only
  def read_only?; read_only; end

  # should this model create a new empty record by default?
  attr_accessor :auto_new
  def auto_new?; auto_new; end
  
  signals(
    # index where error occurred, value, message
    'data_error(QModelIndex,QVariant,QString)',
    # top_left, bottom_right
    'dataChanged(const QModelIndex&,const QModelIndex&)'
  )
  
  def initialize( parent = nil )
    super
    @metadatas = []
  end
  
  def fields=( arr )
    @fields = arr
    
    #reset these
    @metadatas = []
    @dots = nil
    @labels = nil
    @attributes = nil
    @attribute_paths = nil
  end
  
  def dots
    @dots ||= fields.map {|x| x.column }
  end
  
  def labels
    @labels ||= fields.map {|x| x.label }
  end
  
  def attributes
    @attributes ||= fields.map {|x| x.attribute }
  end
  
  def attribute_paths
    @attribute_paths ||= fields.map {|x| x.attribute_path }
  end
  
  def collection=( arr )
    @collection = arr
    # fill in an empty record for data entry
    if collection.size == 0 && auto_new?
      collection << model_class.new
    end
  end
  
  def sort( col, order )
    puts 'sort'
    puts "col: #{col.inspect}"
    #~ Qt::AscendingOrder
    #~ Qt::DescendingOrder
    puts "order: #{order.inspect}"
    super
  end
  
  # this is called for read-only tables.
  def match( start_index, role, search_value, hits, match_flags )
    #~ Qt::MatchExactly	0	Performs QVariant-based matching.
    #~ Qt::MatchFixedString	8	Performs string-based matching. String-based comparisons are case-insensitive unless the MatchCaseSensitive flag is also specified.
    #~ Qt::MatchContains	1	The search term is contained in the item.
    #~ Qt::MatchStartsWith	2	The search term matches the start of the item.
    #~ Qt::MatchEndsWith	3	The search term matches the end of the item.
    #~ Qt::MatchCaseSensitive	16	The search is case sensitive.
    #~ Qt::MatchRegExp	4	Performs string-based matching using a regular expression as the search term.
    #~ Qt::MatchWildcard	5	Performs string-based matching using a string with wildcards as the search term.
    #~ Qt::MatchWrap	32	Perform a search that wraps around, so that when the search reaches the last item in the model, it begins again at the first item and continues until all items have been examined.
    #~ super
    []
  end
  
  #~ def build_dots( dots, attrs, prefix="" )
    #~ attrs.inject( dots ) do |cols, a|
      #~ if a[1].respond_to? :attributes
        #~ build_keys(cols, a[1].attributes, prefix + a[0] + ".")
      #~ else
        #~ cols << prefix + a[0]
      #~ end
    #~ end
  #~ end
  
  # cache metadata (ActiveRecord#column_for_attribute) because it's not going
  # to change over the lifetime of the table
  # if the column is an attribute, create a ModelColumn
  # TODO use ActiveRecord::Base.reflections instead
  def metadata( column )
    if @metadatas[column].nil?
      meta = model_class.columns_hash[attributes[column].to_s]
      if meta.nil?
        meta = model_class.columns_hash[ "#{attributes[column]}_id" ]
        if meta.nil?
          return nil
        else
          @metadatas[column] = ModelColumn.new( attributes[column], :association, meta )
        end
      else
        @metadatas[column] = meta
      end
    end
    @metadatas[column]
  end
  
  def add_new_item
    # 1 new row
    begin_insert_rows( Qt::ModelIndex.invalid, row_count, row_count )
    collection << model_class.new
    end_insert_rows
  end
  
  # rows is a collection of integers specifying row indices to remove
  # TODO call begin_remove and end_remove around the whole block
  def remove_rows( rows )
    # delete from the end to avoid holes affecting the indexing
    rows.sort.reverse.each do |index|
      # remove the item from the collection
      begin_remove_rows( Qt::ModelIndex.invalid, index, index )
      removed = collection.delete_at( index )
      end_remove_rows
      # destroy the db object, and its table row
      removed.destroy
    end
  end
  
  # save the AR model at the given index, if it's dirty
  def save( index )
    item = collection[index.row]
    return false if item.nil?
    if item.changed?
      if item.valid?
        item.save
      else
        false
      end
    else
      # AR model not changed
      true
    end
  end
  
  def rowCount( parent = nil )
    collection.size
  end

  def row_count
    collection.size
  end
  
  def columnCount( parent = nil )
    dots.size
  end
  
  def column_count
    dots.size
  end
  
  def flags( model_index )
    retval = super
    # TODO don't return IsEditable if the model is read-only
    if model_index.metadata.type == :boolean
      retval = item_boolean_flags
    end
    
    # read-only
    unless model_index.field.read_only? || model_index.entity.readonly? || read_only?
      retval |= qt_item_is_editable.to_i 
    end
    retval
  end
  
  def reload_data( options = {} )
    # renew cache
    self.collection = self.collection.renew( options )
    # tell the UI we had a major data change
    reset
  end

  # values for horizontal and vertical headers
  def headerData( section, orientation, role )
    value = 
    case role
      when qt_display_role
        case orientation
          when Qt::Horizontal
            labels[section]
          when Qt::Vertical
            # don't force a fetch from the db
            if collection.cached_at?( section )
              collection[section].id
            else
              section
            end
        end
        
      when qt_text_alignment_role
        case orientation
          when Qt::Vertical
            Qt::AlignRight | Qt::AlignVCenter
        end
          
      when Qt::SizeHintRole
        # anything other than nil here makes the headers disappear.
        nil
        
      when qt_tooltip_role
        case orientation
          when Qt::Horizontal
            fields[section].tooltip
            
          when Qt::Vertical
            case
              when !collection[section].errors.empty?
                'Invalid data'
              when collection[section].changed?
                'Unsaved changes'
            end
        end
        
      when qt_background_role
        if orientation == Qt::Vertical
          case
            when !collection[section].errors.empty?
              Qt::Color.new( 'orange' )
            when collection[section].changed?
              Qt::Color.new( 'yellow' )
          end
        end
        
      else
        #~ puts "headerData section: #{section}, role: #{const_as_string(role)}" if $options[:debug]
        nil
    end
    
    return value.to_variant
  end
  
  # Provide data to UI.
  def data( index, role = qt_display_role )
    #~ puts "data for index: #{index.inspect} and role: #{const_as_string role}"
    begin
      retval =
      case role
        when qt_display_role, qt_edit_role
          # boolean values generally don't have text next to them in this context
          # check explicitly to avoid fetching the entity from
          # the model's collection when we don't need to
          unless index.metadata.type == :boolean
            begin
              value = index.gui_value
              unless value.nil?
                index.field.do_format( value )
              end
            rescue Exception => e
              puts e.backtrace
            end
          end
          
        when qt_checkstate_role
          if index.metadata.type == :boolean
            index.gui_value ? qt_checked : qt_unchecked
          end
          
        when qt_text_alignment_role
          index.field.alignment
        
        # these are just here to make debug output quieter
        when qt_size_hint_role;
        
        # show field with a red background if there's an error
        when qt_background_role
          Qt::Color.new( 'red' ) if index.has_errors?
          
        when qt_font_role;
        when qt_foreground_role
          if index.field.read_only? || index.entity.readonly? || read_only?
            Qt::Color.new( 'dimgray' )
          end
          
        when qt_decoration_role;
        
        when qt_tooltip_role
          case
            # show ActiveRecord validation errors
            when index.has_errors?
              index.errors.join("\n")
              
            # provide a tooltip when an empty relational field is encountered
            when index.metadata.type == :association
              index.field.delegate.if_empty_message
            
            # read-only field
            when index.field.read_only?
              'Read-only'
          end    
        else
          puts "data index: #{index}, role: #{const_as_string(role)}" if $options[:debug]
          nil
      end
      
      # return a variant
      retval.to_variant
    rescue Exception => e
      puts e.backtrace
      puts "#{index.inspect} #{value.inspect} #{index.entity.inspect} #{e.message}"
      nil.to_variant
    end
  end

  # data sent from UI
  def setData( index, variant, role = qt_edit_role )
    if index.valid?
      case role
      when qt_edit_role
        # Don't allow the primary key to be changed
        return false if index.attribute == model_class.primary_key.to_sym
        
        if ( index.column < 0 || index.column >= dots.size )
          raise "invalid column #{index.column}" 
        end
        
        type = index.metadata.type
        value = variant.value
        
        # translate the value from the ui to something that
        # the AR model will understand
        begin
          index.gui_value =
          case
            when value.class.name == 'Qt::Date'
              Date.new( value.year, value.month, value.day )
              
            when value.class.name == 'Qt::Time'
              Time.new( value.hour, value.min, value.sec )
              
            # allow flexibility in entering dates. For example
            # 16jun, 16-jun, 16 jun, 16 jun 2007 would be accepted here
            # TODO need to be cleverer about which year to use
            # for when you're entering 16dec and you're in the next
            # year
            when type == :date && value =~ %r{^(\d{1,2})[ /-]?(\w{3})$}
              Date.parse( "#$1 #$2 #{Time.now.year.to_s}" )
            
            # if a digit only is entered, fetch month and year from
            # previous row
            when type == :date && value =~ %r{^(\d{1,2})$}
              previous_entity = collection[index.row - 1]
              # year,month,day
              Date.new( previous_entity.date.year, previous_entity.date.month, $1.to_i )
            
            # this one is mostly to fix date strings that have come
            # out of the db and been formatted
            when type == :date && value =~ %r{^(\d{2})[ /-](\w{3})[ /-](\d{2})$}
              Date.parse( "#$1 #$2 20#$3" )
            
            # allow lots of flexibility in entering times
            # 01:17, 0117, 117, 1 17, are all accepted
            when type == :time && value =~ %r{^(\d{1,2}).?(\d{2})$}
              Time.parse( "#$1:#$2" )
              
            else
              value
          end
          
          emit dataChanged( index, index )
          # value conversion was successful
          true
        rescue Exception => e
          puts e.backtrace.join( "\n" )
          puts e.message
          emit data_error( index, variant, e.message )
          # value conversion was not successful
          false
        end
        
      when qt_checkstate_role
        if index.metadata.type == :boolean
          index.entity.toggle( index.attribute )
          true
        else
          false
        end
      
      # user-defined role
      # TODO this only works with single-dotted paths
      when qt_paste_role
        if index.metadata.type == :association
          field = index.field
          association_class = field.class_name.constantize
          candidates = association_class.find( :all, :conditions => [ "#{field.attribute_path[1]} = ?", variant.value ] )
          case candidates.size
            when 0; puts "No match for #{variant.value}"
            when 1; index.attribute_value = candidates[0]
            else; puts "Too many for #{variant.value}"
          end
        else
          index.attribute_value = variant.value
        end
        true
        
      else
        puts "role: #{role.inspect}"
        true
        
      end
    else
      false
    end
  end
  
  def like_operator
    case model_class.connection.adapter_name
      when 'PostgreSQL'; 'ilike'
      else; 'like'
    end
  end
  
  # return a set of indexes that match the search criteria
  # TODO this implementation is very un-ruby.
  def search( start_index, search_criteria )
    # get the search value parameter, in SQL format
    search_value =
    if search_criteria.whole_words?
      "% #{search_criteria.search_text} %"
    else
      "%#{search_criteria.search_text}%"
    end

    # build up the ordering conditions
    bits = collection.build_sql_find( start_index.entity, search_criteria.direction )
    
    # do the conditions for the search value
    conditions =
    if start_index.field.is_association?
      # for related tables
      # TODO this will only work with a path value with no dots
      "#{start_index.field.path} #{like_operator} :search_value"
    else
      # for this table
      "#{model_class.connection.quote_column_name( start_index.field_name )} #{like_operator} :search_value"
    end
    
    # add ordering conditions
    conditions += ( " and " + bits[:sql] ) unless search_criteria.from_start?
    
    params = { :search_value => search_value }
    params.merge!( bits[:params] ) unless search_criteria.from_start?
    
    # find the first match
    entity = model_class.find(
      :first,
      :conditions => [ conditions, params ],
      :order => search_criteria.direction == :forwards ? collection.order : collection.reverse_order,
      :joins => ( start_index.field.meta.name if start_index.field.is_association? )
    )
    
    # return matched indexes
    if entity != nil
      found_row = collection.index_for_entity( entity )
      [ create_index( found_row, start_index.column ) ]
    else
      []
    end
  end
  
  def field_for_index( model_index )
    fields[model_index.column]
  end
  
end

end #module
