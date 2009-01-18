
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
    @account_text = '1111'

    @clusters = []
    16.downto(1) do |n|
      @clusters << Computer.find_cluster(n)
    end
  end
end
