require 'active_record'

module MultipleDatabases

  def mod_sqlite
    if connection.adapter_name.eql?("SQLite3")
      db = connection.instance_variable_get(:@connection)
      db.create_function("regexp", 2) do |func, expr, value|
        begin
          if value.to_s && value.to_s.match(Regexp.new(expr.to_s))
            func.set_result 1
          else
            func.set_result 0
          end
        rescue => e
          puts "error: #{e}"
        end
      end
    end
  end

  def multi_db(params = {})
    params = {:path => "#{APP_DIR}/config/databases", :file => "#{self.to_s.downcase}.yml"}.merge( params )
    dbinfo = YAML.load_file("#{params[:path]}/#{params[:file]}")
    self.abstract_class = true
    establish_connection( dbinfo[INDIGO_ENV] )
    mod_sqlite
  end
end

class ActiveRecord::Base
  extend MultipleDatabases

  def self.reload(instances, options={})
    return if instances.empty?
    options = {:conditions=> ["#{primary_key} IN (?)",instances.map(&:id)], :order => "#{primary_key} ASC"}.merge(options)
    new_instances = find(:all,  options)
    instances.each_with_index do |instance, index|
      instance.clear_aggregation_cache
      instance.clear_association_cache
      new_attrs = new_instances[index].instance_variable_get('@attributes')
      instance.instance_variable_get( '@attributes' ).update( new_attrs )
      instance.after_reload if instance.respond_to? :after_reload
    end
  end
end
