
class Notify
  attr_accessor :body
  attr_reader :id
  attr_reader :time
  
  def self.find_all_by_name(name) 
    Dir["#{CONFIG['notify_path']}#{name}.*"].sort.collect do |path|
      new(path, IO.readlines(path), File.new(path).mtime)
    end    
  end
  
  def self.create(name,text)
    Debug.log.debug "notify create '#{text}' @ #{name}"
    count=0
    path=""
    begin
      path = "#{CONFIG['notify_path']}#{name}.#{count}"
      count += 1    
    end while File.exists?(path)
    update(path, text) unless text == ""
  end

  def self.update(id, text)  
      File.open(id,"w") { |notify| notify.print text }
  end
      
  def delete
    `rm #{self.id}`
  end
  
  def save
    Notify.update(self.id, self.body)
  end
   
  def initialize(id, body, time)
    @id, @body, @time = id, body.to_s.chomp, time
  end

end
