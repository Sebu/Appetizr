require 'rubygems'
require 'active_record'

Dir["#{File.dirname(__FILE__)}/*.rake"].each { |ext| load ext }
Dir["lib/tasks/**/*.rake"].sort.each { |ext| load ext }

task :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
