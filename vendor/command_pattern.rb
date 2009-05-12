

module CommandPattern
  class CommandStack
    attr_reader :commands, :desc
    def initialize(desc="stack")
      @commands = []
      @mode = :single
      @desc = desc
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
      if @commands.last
        Debug.log.debug "undo:  #{@commands.last.desc}"
        @commands.last.undoit 
        @commands.pop
      end
    end
    def empty?
      @commands.empty?
    end
  end

  class Command
    attr_reader :desc
    def initialize(desc, &doit)
      @desc = desc
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

  def undo
    commands_end
    cmds.undo
  end
  
  def cmds  
    @cmds ||= CommandStack.new
  end
  def command(desc="command", &block)
    cmd = Command.new(desc, &block)
    cmds << cmd
    cmd
  end


  # compound commmands
  def commands_begin(desc)
    @cmds_stacks ||= []
    @cmds_stacks.push cmds
    new_cmds = CommandStack.new(desc)
    @cmds = new_cmds
  end
  
  def commands_end
    if @cmds_stacks and @cmds_stacks.last
      new_cmds = @cmds
      @cmds = @cmds_stacks.last
      @cmds << new_cmds unless new_cmds.empty?
      @cmds_stacks.pop
    end
  end
  
end

=begin
class Test
 include CommandPattern

  def initialize
    command("wurst") do
      puts "SDSD" 
    end.un do
      puts "DSDS"
    end.run
    commands_begin "macro test"
    command("wurst1") do
      puts "SDSD" 
    end.un do
      puts "DSDS"
    end.run
    command("wurst2") do
      puts "SDSD" 
    end.un do
      puts "DSDS"
    end.run
    commands_end
    
   undo
   commands_begin("SDSD")
   undo
    
  end
end

Test.new
=end
