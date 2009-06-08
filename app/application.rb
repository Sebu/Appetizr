
require 'vendor/indigo'
include Indigo

application do
  option :usage do puts "huhu" end
  args = parse_options
  visit "%ss/1" % (args[0] || "main")
end

