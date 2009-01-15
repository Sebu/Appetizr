
namespace :db do

  desc "migrate databases"
  task :migrate => :environment do
    db_paths.each do |path| 
      db_name = connect_db(path)
      ActiveRecord::Migrator.migrate("db/migrate/#{db_name}/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end
  end

  namespace :schema do
    desc "dump all active record DB schemas"
    task :dump => :environment do
	    require 'active_record/schema_dumper'
      db_paths.each do |path| 
        db_name = connect_db(path)
    	  File.open(ENV['SCHEMA'] || "db/schemas/#{db_name}.rb", "w") do |file|
    	    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    	  end
      end
	  end
    desc "load all active record DB schemas"
    task :load => :environment do
      db_paths.each do |path| 
        db_name = connect_db(path)
        load "db/schemas/#{db_name}.rb"
      end
	  end
  end

  def db_paths
    paths ||= Dir["#{APP_DIR}/config/databases/*.yml"]
  end

  def connect_db(path)
    ActiveRecord::Base.establish_connection( YAML.load_file(path)[INDIGO_ENV] )
    File.basename(path, '.yml')
  end
end
