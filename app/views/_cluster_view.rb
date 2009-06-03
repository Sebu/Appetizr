

flow do
  stack do
    @cluster.select{|i| i.id[-1..-1].to_i>=5 }.reverse_each do | c |
      render "computer_button", :computer => c
    end
  end
  stack do
    @cluster.select{|i| i.id[-1..-1].to_i<5 }.reverse_each do | c |
      render "computer_button", :computer => c
    end
  end
end

