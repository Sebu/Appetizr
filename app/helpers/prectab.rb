

class Prectab
  def self.scan_file(filename)
    prectab = {}
    
    # get current day
    day =  2 #Time.now.wday
    
    Debug.log.debug "day: #{day}"
    
    if File.exist?(filename)
      prectab = parsePrectab(filename, day)      
    else
      Debug.log.debug "can't find prectab file: #{filename} creating empty list"
    end
    
    Debug.log.debug "...done scanning prectab"
    return prectab
  end  


  def self.parsePrectab(file, today)
    prectab = {}
    prev = nil
    day = today-1
    return prectab unless 0.upto(5).include?(day)
    8.upto(23) { |h| prectab[h] = {} }
    File.open(file, 'r').each do |line|
      ln = line.split('\n')
      tokens = ln[0].split(' ')
      next if tokens[0] == "Schul"
      0.upto(9) do |i|
        infos = tokens[i*5+day+1].split(',')
        hour = i+8
        elements = infos.size
        if elements == 2                                    # free
           prev = nil
        elsif elements == 1                                 # prev
          if prev
            data = understand_infos(prev, tokens)
            data.each_pair { |name, fields| prectab[hour][name] = fields }
          end
        else                                                # entry
          prev = infos
          data = understand_infos(infos, tokens)
          data.each_pair { |name, fields| prectab[hour][name] = fields }
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


