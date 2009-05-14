

module Indigo
  class PrinterJob
    attr_reader :id, :size, :user, :printer
    def initialize(id, user, size, printer)
      @id = id
      @size = size
      @user = user
      @printer = printer
    end
    def cancel
      Printer.cancel(self)
    end
    def move_to(printer)
      Printer.move_job_to(self, printer)
    end
  end

  class Printer
    attr_reader :name
    
    def self.default
      @default ||= Printer.new(Printer.default_name)
    end
    
    def self.printers
      @printers ||= Printer.printer_names.collect {|name| Printer.new(name) }
    end
    
#    def self.jobs
#      `LANG=EN; lpstat -o`
#    end
    
    def initialize(name)
      @name = name
    end
    
    def default?
      self.name == Printer.default_name
    end

    def cancel(job)
      Printer.cancel(job)
    end
    
    def self.cancel(job)
      `cancel #{job.id}`
    end
    
    def enabled?
      `LANG=EN; lpstat -p #{@name}`.split(" ")[4] == "enabled"
    end

    def accepts?
      `LANG=EN; lpstat -a #{@name}`.split(" ")[1] == "accepting"
    end

    def self.job_count
      Printer.jobs_command.split("\n").size
    end

    def job_count
      Printer.jobs_command(self.name).split("\n").size
    end
    
    def jobs
      status = Printer.jobs_command(self.name)
      jobs = status.collect do |line|
        infos = line.split(" ")
        id = infos[0]
        user = infos[1]
        size = infos[2]
        PrinterJob.new(id, user, size, self)
      end
    end
    
    protected
    def self.jobs_command(name="")
      `LANG=EN; lpstat -o #{name}`
    end
     
    def self.default_name
      `LANG=EN; lpstat -d`.chomp!.split(": ")[1]
    end
    def self.printer_names
      text = `LANG=EN; lpstat -p`
      text.collect { |printer| printer.split(" ")[1] }
    end
  end
end

#p Indigo::Printer.job_count
#p Indigo::Printer.default.job_count
#p Indigo::Printer.default.accepts?
#p Indigo::Printer.printers

