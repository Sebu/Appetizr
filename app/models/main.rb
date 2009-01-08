
require 'computer'

class Main 
  include Indigo::ActiveNode
  include Indigo::ObserveAttr
  obs_attr :name
  obs_attr :account_text
  obs_attr :scan_string
  attr_accessor :clusters
  
  
  def initialize
    @name = 'indigoAdm'
    @account_text = '1111'

    cluster1 = Computer.find_cluster(1)
    cluster2 = Computer.find_cluster(2)
    cluster3 = Computer.find_cluster(3)
    cluster4 = Computer.find_cluster(4)
    cluster5 = Computer.find_cluster(5)
    cluster6 = Computer.find_cluster(6)

    cluster7 = Computer.find_cluster(7)
    cluster8 = Computer.find_cluster(8)
    cluster9 = Computer.find_cluster(9)
    cluster10 = Computer.find_cluster(10)
    cluster11 = Computer.find_cluster(11)
    cluster12 = Computer.find_cluster(12)
    cluster13 = Computer.find_cluster(13)
    cluster14 = Computer.find_cluster(14)
    cluster15 = Computer.find_cluster(15)
    cluster16 = Computer.find_cluster(16)

    @clusters = [cluster16, cluster15, cluster14, cluster13, cluster12, cluster11, cluster10, cluster9, cluster8, cluster7,
                 cluster6,cluster5, cluster4, cluster3, cluster2, cluster1] 

  end
end
