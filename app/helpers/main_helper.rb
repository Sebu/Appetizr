
module MainHelper
  def user_list_format(a)
    return if a.empty?
    "<span size='x-small'>#{a.tr(" ","\n")}</span>"
  end

  def prectab_format(prectab)
    "<b><span size='x-small' color='#FEFEAA'>#{prectab}</span></b>" 
  end
  
  
  def color_please(value)
    value ? "#82c927" : "#FFFFAA"
  end


  def code_to_color(code, computer)
    if computer.prectab and computer.user == ""
      CONFIG['colors'][8]
    else
      CONFIG['colors'][computer.color]
    end
  end
  
end
