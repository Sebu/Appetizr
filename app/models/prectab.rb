
# prectab with all days data (prectab.changed? prectab.now[])

class Prectab
  @old_hour=0
  @old_day=0
  @prectab = nil
  
  def self.changed?
    if self.hour != @old_hour or self.day != @old_day
      @old_hour = self.hour; @old_day=self.day
      true
    else
      false
    end
  end

  def self.hour
    Time.now.hour
  end
  
  def self.day
    Time.now.wday
  end
  
  def self.soon
    self.today[self.hour+1]
  end
  
  def self.now
    self.today[self.hour]
  end

  def self.prectab
    @prectab ||= scan_file(CONFIG["prectab_path"])
  end
     
  def self.today
    self.prectab[self.day]
  end
  
  def self.scan_file(filename)
    
    prectab = if File.exist?(filename)
                parsePrectab(filename)      
              else
                Debug.log.debug "can't find prectab file: #{filename} creating empty list"
                {}
              end
    
    Debug.log.debug "...done scanning prectab"
    return prectab
  end  


  def self.parsePrectab(file)
    prectab = {}
    prev = nil
    0.upto(6) { |h| prectab[h] = Hash.new { |hash, key| hash[key] = {} } }
    File.open(file, 'r').each do |line|
      tokens = line.split('\n')[0].split(' ')
      1.upto(5) do |day|
        0.upto(9) do |i|
          infos = tokens[i*5+day].split(',')
          hour = i+8
          case infos.size
          when 2: prev = nil  # free
          when 1:             # prev
            if prev
              data = understand_infos(prev, tokens)
              data.each_pair { |name, fields| prectab[day][hour][name] = fields }
            end
          else                # entry
            prev = infos
            data = understand_infos(infos, tokens)
            data.each_pair { |name, fields| prectab[day][hour][name] = fields }
          end
        end
      end
    end
    return prectab
  end


  def self.understand_infos(infos, tokens)
    result = {}
    count = (infos.size-2)/3 
    0.upto(count-1) do |i|                                      
      index = 2 + (i*3)
      room = tokens[0]
      result[infos[index]] = [infos[index+1], room, infos[index+2]]
    end
    return result
  end
end


