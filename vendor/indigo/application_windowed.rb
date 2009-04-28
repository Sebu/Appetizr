


module Indigo
module Application
module Windowed

  def run
    #Qt Stuff
    a = Qt::Application.new(ARGV)
    t = IdleKicker.new

    name = CONFIG["controller"].to_s
    @main_view = eval "#{name.capitalize}Controller.one.show"

    #Qt Stuff
    a.exec 
  end

end

end
end


#Qt Stuff
#fuck da ship workaround for green ruby threads and qt :/
#IdleKicker
#0 timeout would be better but doesn't work :(
class IdleKicker < Qt::Object

  slots :give_up

  def give_up()
  end

  def initialize
    super

    timer = Qt::Timer.new
    connect(timer, SIGNAL(:timeout), self,  nil )  #SLOT(:give_up)
    timer.start(0)
  end
end





