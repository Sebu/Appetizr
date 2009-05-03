

module CommandPattern
  class CommandStack
    def initialize
      @commands = []
      @mode = :single
    end
    def <<(cmd)
      @commands.push cmd
    end
    # run all commands
    def run
      @commands.each { |c| c.doit }
    end
    def undoit
      @commands.reverse_each { |c| c.undoit }
    end
    def doit
      @commands.last.run
    end
    def undo
      @commands.last.undoit if @commands.last
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
    def undoit
      @undoit.call
      self
    end
  end

  def commands_start
    @mode = :multi
    @cmds_stacks ||= []
    @cmds_stacks.push cmds
    new_cmds = CommandStack.new
    @cmds << new_cmds
    @cmds = new_cmds
  end
  
  def commands_end
    if @mode == :multi then
      @cmds = @cmds_stacks.last
      @cmds_stacks.pop
    end
    @mode = :single
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
