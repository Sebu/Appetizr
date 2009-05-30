

stack do 
  @cluster.reverse_each do | c |
    render "computer_button", :c => c
  end
end

