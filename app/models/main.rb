
class Main 
  include Indigo::ActiveNode
  include ObserveAttr

  attr_accessor :account_text, :scan_string, :status, :user_list, :printers
  obsattr :account_text
  obsattr_writer :printers
  obsattr_writer :scan_string
  obsattr_writer :status
  obsattr :user_list
  attr_accessor :clusters, :computers
  
  
  def initialize
    @printers = Indigo::Printer.printers
    @user_list = ["seb"]
    @account_text = ""
    @scan_string = "220683"
    @status = ["indigoAdm", "gestartet", "application-x-ruby"]
    @clusters = []
    @computers = {}
  
    16.downto(1) do |n|
      @clusters << Computer.find_cluster(n)
    end
  end
  
  
end
