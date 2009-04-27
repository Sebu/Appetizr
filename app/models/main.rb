
class Main 
  include Indigo::ActiveNode
  include ObserveAttr

  attr_accessor :account_text, :scan_string, :log
  obsattr_reader :account_text
  obsattr :scan_string
  obsattr :log
  attr_accessor :clusters, :computers
  
  
  def initialize
    @account_text = "seb"
    @log = "log start\n"
    @clusters = []
    @computers = []
    16.downto(1) do |n|
      new_computers = Computer.find_cluster(n)
      @clusters << new_computers
      @computers = new_computers + @computers
    end
  end
  
  
end
