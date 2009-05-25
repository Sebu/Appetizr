
class Main 
  include Indigo::ActiveNode
  include ObserveAttr

  attr_accessor :account_text, :pool_store, :account_list, :pool_store, :status_list, :scan_string, :user_list, :printers
  observe_attr :account_text, :scan_string, :user_list, :printers
  attr_accessor :clusters, :computers
  
  def status=(value)
    title,body,icon = value
    time = Time.now.strftime("%H:%M:%S")
    new_body = body.tr("\n"," ")
    @status_list.add_object(["#{time}","<b>#{title}</b> #{new_body}"])
    @status = value
  end
  
  def status
    @status
  end
  
  observe_attr :status
    
  def initialize
    @account_list = AccountList.new
    @status_list = StatusList.new
    @printers = Indigo::Printer.printers
    @user_list = Gtk::ListStore.new(String,String)
    [["seb","sdsd"]].each { |v| iter = user_list.append; iter[0] = v[0]; iter[1] = v[1] }
    @account_text = ""
    @scan_string = "220683"
    self.status = ["indigoAdm", "gestartet", "application-x-ruby"]
    @clusters = []
    @computers = {}
  

    
    16.downto(1) do |n|
      @clusters << Computer.find_cluster(n)
    end
  end
  
  
end
