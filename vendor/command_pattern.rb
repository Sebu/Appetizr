

module CommandPattern
  class CommandStack
    def initialize
      @commands = []
    end
    def <<(cmd)
      @commands.push cmd
    end
    def run
      @commands.last.run
    end
    def undo
      @commands.last.undo if @commands.last
      @commands.pop
    end
  end

  class Command
    def initialize(&doit)
      @doit = doit
      self
    end
    def re(&redoit)
      @doit = redoit
      self
    end
    def un(&undoit)
      @undoit = undoit
      self
    end
    def run
      @doit.call
      self
    end
    def undo
      @undoit.call
      self
    end
  end

  def cmds  
    @cmds ||= CommandStack.new
  end
  def command(&block)
    cmd = Command.new(&block)
    cmds << cmd
    cmd
  end
end

#class Test
#  include CommandPattern
#
#  def initialize
#    command do
#      puts "SDSD" 
#    end.un do
#      puts "DSDS"
#    end.run

#  end
#end

#Test.new
