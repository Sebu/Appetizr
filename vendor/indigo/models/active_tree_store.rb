require 'indigo/models/active_column'

=begin

ActiveTreeStore is used to help generate the correct model data
(Gtk::TreeStore) to be used for a Gtk::TreeView

example:

user_list_model = ActiveTreeStore.new(User, [:login, :avatar])
user_list_model.apply_to_tree(user_list_tree_view)
user_list_model.populate( User.find(:all, :order => 'login') )

=end

class Indigo::ActiveTreeStore < Gtk::TreeStore
    
  ##
  ## example:
  ## user_list_model = ActiveTreeStore.new(User, [:login, :avatar])
  ##
  def initialize(ar_class, cols=[], options={})
    @columns = []
    id = 1
    cols.each do |column_name|
      ar_columns = ar_class.columns.select {|c| c.name.to_sym == column_name.to_sym }
      if ar_columns
        @columns << Indigo::ActiveColumn.create(id, ar_columns.first)
        id += 1
      end
    end
    column_classes = [ar_class] # object is at column position 0
    column_classes += array_of_classes_from_columns(@columns)
    super(*column_classes)
  end

  ##
  ## associates a Gtk::TreeView widget with self
  ## (a tree model). 
  ##
  def apply_to_tree(treeview)
    treeview.model = self
    puts 'apply_to_tree %s' % treeview.name
    y @columns
    @columns.each do |column|
      treeview.append_column(column.view)
      puts 'added column %s' % column.class
    end
  end
  
  ##
  ## takes an array of activerecord objects
  ## and generates the model data from it.
  ##
  def populate(ar_array)
    clear
    ar_array.each do |object|
      self.add(object)
    end
  end
    
  ##
  ## returns an array of Gtk::TreeViewColumns with the appropriate renderers
  ## for our model data
  ##
  def view_columns
    view_columns = []
    @columns.each do |column|
      view_columns << column.view
    end
    return view_columns
  end
  
  def get_object(iter)
     iter[0]
  end

  # adds an active record object to the tree store.
  def add(object)
    iter = self.append(nil)
    @columns.each do |column|
      iter[column.id] = column.data_value(object)
    end
    iter[0] = object
  end

  # updates the display in the tree/list of the given active record object
  def refresh(object)
    self.each do |model,path,iter| 
      if iter[0].id == object.id
        @columns.each do |column|
          set_value(iter, column.id, column.data_value(object))
        end
        break
      end
    end
  end

  private
  
  def array_of_classes_from_columns(columns)
    class_array = []
    columns.each do |column|
      class_array << column.data_class
    end
    class_array
  end
  
end


