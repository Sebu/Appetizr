
require 'active_record'

module MultipleDatabases

  def mod_sqlite
    if connection.adapter_name.eql?("SQLite")
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
    default_params = { :path => "#{APP_DIR}/resources/config/databases", :file => "#{self.to_s.downcase}.yml"  }
    params = default_params.merge( params )
    dbinfo = YAML.load_file("#{params[:path]}/#{params[:file]}")
    self.abstract_class = true
    p dbinfo[INDIGO_ENV]
    establish_connection( dbinfo[INDIGO_ENV] )
    mod_sqlite
  end
end

class ActiveRecord::Base
  extend MultipleDatabases

end
