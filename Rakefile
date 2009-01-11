require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'rubygems'
require 'active_record'

task :migrate => :environment do
  require 'db/migrate/init_computer'
  require 'db/migrate/init_adm'
end

task :environment do
  require 'config/environment'
  #ActiveRecord::Base.logger = Logger.new(STDOUT)
end




