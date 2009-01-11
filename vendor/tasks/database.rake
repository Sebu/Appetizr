
namespace :db do
  task :migrate => :environment do
    require 'db/migrate/init_computer'
    require 'db/migrate/init_adm'
  end
end
