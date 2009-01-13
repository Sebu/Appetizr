
class Main 
  include Indigo::ActiveNode
  include ObserveAttr
  obs_attr :name
  obs_attr :account_text
  obs_attr :scan_string
  attr_accessor :clusters
  
  
  def initialize
    @name = 'indigoAdm'
    @account_text = '1111'

    @clusters = []
    16.downto(1) do |n|
      @clusters << Computer.find_cluster(n)
    end
  end
end
