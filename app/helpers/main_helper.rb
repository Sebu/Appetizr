
module MainHelper
  def user_list_format(a)
    return if a.empty?
    "<span size='x-small'>#{a.tr(" ","\n")}</span>"
  end

  def prectab_format(prectab)
    "<u><b><span size='small' color='#FEFEAA'>#{prectab}</span></b></u>" 
  end
  
  
  def color_please(value)
    value ? "#00ff00" : "#ffff00"
  end


  def code_to_color(code, computer)
    if computer.prectab and computer.user == ""
      CONFIG['colors'][8]
    else
      CONFIG['colors'][computer.color]
    end
  end
  
end
