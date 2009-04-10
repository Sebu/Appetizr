
class Main 
  include Indigo::ActiveNode
  include ObserveAttr
  attr_accessor :name, :account_text, :scan_string
  obs_attr :name
  obsattr_reader :account_text
  obs_attr :scan_string
  attr_accessor :clusters
  
  
  def initialize
    @name = 'indigoAdm'
    @account_text = 'jeder'

    @clusters = []
    computers = []
    16.downto(1) do |n|
      new_computers = Computer.find_cluster(n)
      @clusters << new_computers
      computers = new_computers + computers
    end
    refresh = Thread.new {
      while true
        Computer.reload(computers)
        sleep(15)
      end  
    }
  end
end
