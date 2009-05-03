
class Main 
  include Indigo::ActiveNode
  include ObserveAttr

  attr_accessor :account_text, :scan_string, :status
  obsattr :account_text
  obsattr_writer :scan_string
  obsattr_writer :status
  attr_accessor :clusters, :computers
  
  
  def initialize
    @account_text = "seb"
    @scan_string = "1234"
    @status = ["rubyAdm", "gestartet", "application-x-ruby"]
    @clusters = []
    
  
    16.downto(1) do |n|
      @clusters << Computer.find_cluster(n)
    end
  end
  
  
end
