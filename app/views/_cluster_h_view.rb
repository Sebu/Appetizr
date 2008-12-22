

flow do 
  @cluster.each do | c |
    render "computer_button", :c => c
  end
end

