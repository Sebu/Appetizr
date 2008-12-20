

flow do
  stack do
    stretch
    @cluster.select{|i| i.Cname[-1..-1].to_i>=5 }.reverse_each do | c |
      render "computer_button", :c => c
    end
  end

  stack do
    stretch
    @cluster.select{|i| i.Cname[-1..-1].to_i<5 }.reverse_each do | c |
      render "computer_button", :c => c
    end
  end
  stretch
end

