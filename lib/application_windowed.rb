
require 'logger'
require 'application'


require 'Qt4'

module Indigo
  module Application
    module Windowed

      def run
       require 'add_controller'
       a = Qt::Application.new(ARGV)
       t = IdleKicker.new
       @main_view = AddController.one.show
       puts @main_view
       a.exec 
      end

    end
  end
end




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
    connect(timer, SIGNAL(:timeout), self,  SLOT(:give_up) )
    timer.start(100)
  end
end




