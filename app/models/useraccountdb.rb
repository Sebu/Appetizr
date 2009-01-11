
require 'indigo/multiple_databases'

class UserAccountDB < ActiveRecord::Base
  multi_db
end


