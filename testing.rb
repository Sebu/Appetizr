
require 'config/environment'
require 'active_record'
require 'models/user'
require 'models/account'
require 'ar_table_model'


app = Qt::Application.new(ARGV)
puts "Die User"
user = User.find_by_alias('1234')


model = ARTableModel.new(user.accounts, ["account"])
table = Qt::TableView.new
table.model = model
table.show
app.exec



