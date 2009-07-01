
class Main 
  include Indigo::ActiveNode
  include ObserveAttr

  attr_accessor :account_text, :pool_store, :account_list, :pool_store, :status_list, :scan_string, :user_list, :printers
  observe_attr :account_text, :scan_string, :user_list, :printers
  attr_accessor :clusters, :computers_cache
  
  #TODO: find better solution
  def status=(value)
    title,body,icon = value
    time = Time.now.strftime("%H:%M:%S")
    new_body = body.tr("\n"," ")
    @status_list << ["#{time}","<b>#{title}</b> #{new_body}"]
    @status = value
  end
  
  def status
    @status
  end
  observe_attr :status
    


  def initialize
    @account_list = AccountList.new
    @status_list = Indigo::ObjectListStore.new(String,String)
    @user_list = Indigo::ObjectListStore.new([["seb","demo user"]])
    @printers = Printer.printers
    @account_text = ""
    @scan_string = "220683"
    self.status = ["indigoAdm", "gestartet", "pyadm_icon", 0]

    @clusters = []
    @computers_cache = {}
    
    1.upto(18) do |n|
      @clusters << Computer.find_cluster(n)
    end
  end
 
  
end
