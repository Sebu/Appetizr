

flow do

  stack do
    stretch
    @cluster[4..-1].reverse_each do | c |    
#   @cluster.select{|i| i.id[-1..-1].to_i>=5 }.reverse_each do | c |
      render "computer_button", :c => c
    end
  end
  stack do
    stretch
    @cluster[0..3].reverse_each do | c |    
#   @cluster.select{|i| i.id[-1..-1].to_i<5 }.reverse_each do | c |
      render "computer_button", :c => c
    end
  end
  stretch
end

