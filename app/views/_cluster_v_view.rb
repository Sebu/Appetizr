

stack do 
  @cluster.reverse_each do | c |
    render "computer_button", :computer => c
  end
end

