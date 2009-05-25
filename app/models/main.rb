
class Main 
  include Indigo::ActiveNode
  include ObserveAttr

  attr_accessor :account_text, :pool_store, :account_table, :pool_store, :scan_string, :status, :user_list, :printers
  observe_attr :account_text, :scan_string, :status, :user_list, :printers
  attr_accessor :clusters, :computers
  
  
  def initialize
    @printers = Indigo::Printer.printers
    @user_list = Gtk::ListStore.new(String,String)
    [["seb","sdsd"]].each { |v| iter = user_list.append; iter[0] = v[0]; iter[1] = v[1] }
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
