

flow  do 
  @cluster.each do | c |
    render "computer_button", :computer => c
  end
end

