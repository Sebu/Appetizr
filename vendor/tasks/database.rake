
namespace :db do

  task :migrate => :environment do
    Dir["#{APP_DIR}/config/databases/*.yml"].each do |path| 
      db_name = File.basename(path, '.yml')
      dbinfo = YAML.load_file(path)
      ActiveRecord::Base.establish_connection( dbinfo[INDIGO_ENV] )
      ActiveRecord::Migrator.migrate("db/migrate/#{db_name}/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end
  end

  namespace :schema do
    task :dump => :environment do
	    require 'active_record/schema_dumper'
      Dir["#{APP_DIR}/config/databases/*.yml"].each do |path| 
        db_name = File.basename(path, '.yml')
        dbinfo = YAML.load_file(path)
        ActiveRecord::Base.establish_connection( dbinfo[INDIGO_ENV] )
    	  File.open(ENV['SCHEMA'] || "db/schemas/#{db_name}.rb", "w") do |file|
    	    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    	  end
      end
	  end
  end

end
