# cups commandline lpstat,lpoptions
# and snmp based printer classes

require 'rexml/document'
require 'open3'

  class PrinterJob
    attr_reader :id, :size, :user, :printer, :time

    def initialize(id, user, size, time, printer)
      @id = id
      @size = size
      @user = user
      @time = time
      @printer = printer
    end
    def cancel
      Printer.cancel(self)
    end
    def move_to(target_name)
      Printer.move_job_to(self, target_name)
    end
  end

  class Printer
    include ObserveAttr
    attr_accessor :name, :job_count, :accepts, :enabled, :display
    observe_attr :job_count, :accepts, :enabled, :display
    
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
      self.enabled = true
      self.accepts = true
    end
    
    def default?
      self.name == Printer.default_name
    end

    def cancel(job)
      Printer.cancel(job)
    end
    
   
    def self.cancel(job)
      `ssh root@#{CONFIG['cups_server']} -- 'cancel #{job.id}'`
    end

    def self.move_job_to(job, target_name)
      `ssh root@#{CONFIG['cups_server']} -- 'lpmove #{job.id} #{target_name}'`
    end 
    
    def enabled?
      self.enabled ||= update_enabled
    end

    def accepts?
      self.accepts ||= update_accepts
    end

    def self.job_count
      Printer.jobs_command.split("\n").size
    end

    def update_snmp
      Open3.popen3("scli -xqc 'show printer display' #{self.name}-pool") { |stdin,stdout,stderr|
        @snmp = stdout.readlines
      }
      doc = REXML::Document.new(@snmp.to_s)
      lcd = doc.elements.collect('scli/devices/printer/display/line') { |ele| ele.text }
      lcd = unless lcd.empty?
              lcd.compact.join("\n")
            else
              "no snmp support"
            end
      case lcd
      when /EMPTY/
        self.enabled = false
      else
        self.enabled = true
      end
      self.display=lcd
    end

    def update_enabled
      self.enabled = `LANG=EN; lpstat -p #{@name}`.split(" ")[4] == "enabled"
    end  

    def update_accepts
      self.accepts = `LANG=EN; lpstat -a #{@name}`.split(" ")[1] == "accepting"
    end  
   
    def update_job_count
      self.job_count = Printer.jobs_command(self.name).split("\n").size
    end    
    
    def update_tray_status
      if @snmp
        IO.popen("scli -xqnc 'show printer inputs' #{@name}-pool").readlines
      end
    end

    def jobs
      status = Printer.jobs_command(self.name)
      jobs = status.collect do |line|
        infos = line.split(" ")
        id = infos[0]
        user = infos[1]
        size = infos[2]
        time = infos[6]
        PrinterJob.new(id, user, size, time, self)
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
      text = `LANG=EN; lpstat -a | grep -v "/"`
      text.collect { |printer| printer.split(" ")[0] }
    end
  end

#p Indigo::Printer.job_count
#p Indigo::Printer.default.job_count
#p Indigo::Printer.default.accepts?
#p Indigo::Printer.printers

