

class MainController < Indigo::Controller
  
  attr_accessor :main_view

  after_initialize :start_threads
  
  #TODO: remove and implicit generate in dnd functions
  def drag_pool_store
    session[:pool_store]
  end

  def drop_pool_store(*args)
    session[:pool_store] = *args
    Main.active.status = ["#{session[:pool_store]['User']}", "von <b>#{session[:pool_store]['Cname']}</b> in store verschoben","trashcan_full"]
  end

  def user_list_format(a)
    "<span size='x-small'>#{a.tr(" ","\n")}</span>"
  end

  def color_please(value)
    value ? "#00ff00" : "#ffff00"
  end

  def prectab_format(prectab)
    "<u><b><span size='small' color='#FEFEAA'>#{prectab}</span></b></u>" 
  end
  
  def code_to_color(code, computer)
  #def code_to_color(computer)
    if computer.prectab and computer.user == ""
      CONFIG['colors'][8]
    else
      CONFIG['colors'][computer.color]
    end
  end

  def cbutton_click(pc)
    unless Main.active.account_list.empty?
      table_register(pc)
    end
  end

  
  def drop_users_on_table(other_pc)
    users = other_pc["User"].split(" ")
    accounts = Account.find_accounts_or_initialize(users)
    fill_accounts(accounts)
    Debug.log.debug accounts
    Debug.log.debug users
  end

 
  def remove_user
    accounts = @account_table.selection
    if !accounts.empty? and confirm t"account.ask_remove"
      accounts.each { |account| Account.delete_all("barcode='#{account.barcode}' AND account='#{account.account}'") }
      puts "SDSD"
      account_string = accounts.collect { |a| a.account }.join(", ")
      Main.active.status = ["#{account_string}", "von Barcode: #{Main.active.scan_string} enfernt","trashcan_full"]
      #fill_accounts(@account_table.model.rows.remove(users))    
    end
  end
  
  
  def table_register(pc)
    new_users = @account_table.selection.collect { |a| a.account } unless Main.active.account_list.empty?
    users_register(new_users, pc)
    Main.active.account_list.clear
  end
  
  

    
  # TODO: merge with users_register methods
  def key_clear(pc)
    old_user, old_color = pc.user, pc.color
    command("key clear") do
      pc.user = ""
      pc.color = 0
      pc.save!
    end.un do
      pc.user = old_user
      pc.color  = old_color
      pc.save!
    end.run
    commands_end
  end

  def users_register(users, pc)
    return if users.empty?
    
    old_user, old_color = pc.user, pc.color
    command("register users") do
      pc.user = users.join(" ") #(pc.User.split(" ") | (users)).join(" ")
      pc.color = CONFIG['color_mapping'][ Account.gen_color(users) ]
      pc.save!
      Main.active.status = ["#{pc.user}", "auf <b>#{pc.id}</b> angemeldet", "chair"]
    end.un do
      pc.user = old_user
      pc.color = old_color
      pc.save!
    end.run
    end

  def drop_user(pc, other_pc)
    #pc = Computer.find(pc_id.id)
    return unless other_pc
    old_user, old_color = pc.user, pc.color
    commands_begin "dnd user"
    command("drop users") do
      pc.user=other_pc["User"]
      pc.color=other_pc["Color"]
      pc.save!
      Main.active.status = ["#{pc.user}", "von <b>#{other_pc['Cname']}</b> auf <b>#{pc.id}</b> verschoben","redo"]
    end.un do
      pc.user = old_user
      pc.color = old_color
      pc.save!
      Main.active.status = ["#{pc.user}", "von <b>#{pc.id}</b> auf <b>#{other_pc['Cname']}</b> verschoben","undo"]
    end.run
     #widgets[pc_id.id].background=code_to_color(nil,pc)
  end



  # in: Account
  def fill_accounts(accounts)
    message = ""
    accounts.each do |account|
      exists = Computer.find(:all, :select=>"Cname", :conditions=> ["User LIKE ?", "%#{account.account}%"])
      exists_string = exists.collect { |pc| pc.id }.join(", ")
      message +="<b>#{account.account}</b> auf <b>#{exists_string}</b>\n" unless exists.empty?
    end
    account_string = accounts.collect { |a| a.account }.join(", ")
    if not accounts or accounts.empty?
      Main.active.status = ["#{Main.active.scan_string}", "hat keinen Account", "barcode"]
    elsif not message == ""
      Main.active.status = ["#{account_string}", "#{t("account.scanned")}\n\n#{message}", "important"]
    else
      Main.active.status = ["#{account_string}", t("account.scanned"), "barcode"] 
    end
    Main.active.account_list.clear
    Main.active.account_list.add_objects(accounts)
    @account_table.select_all
  end


  # TODO: improve code (see also Account.find_account_or_initialize)
  def account_return
    direct_login = []
    users = []
    ulist =  Main.active.account_text.tr("\n ",",").split(",")
    ulist.each do |n| 
      n.strip!
      case n
      when /^.*@[0-9]{2,3}$/ 
        direct_login << n.split("@")
      when /^.{0,8}$/
        users << n
      end
    end
    #p Account.find_accounts(users).private.other_accounts.flatten
    accounts =  users.empty? ? [] : Account.find_accounts_or_initialize(users)
    accounts.collect! { |account| account.all_accounts } if accounts
    accounts.flatten! if accounts
    if !accounts.empty?
      fill_accounts(accounts)
    else
      Main.active.status = ["#{users}", "existiert nicht", "important"]
    end
  end


  # determine barcode type
  def check_scanner_string(scan)
    if    m = /^-[cC]([0-9]{2,3})-$/.match(scan)
      return :key, "c#{m[1]}"
    elsif m = /^16900([0-9]{6})[0-9]{1}$/.match(scan)
      return :matrikel, m[1]
    elsif m = /'^UP-([A-Z]{1})-[a-zA-Z0-9]+-[0-9]{4}$/.match(scan)
      return :card, m[1]
    else
      return :other, "du_affe"
    end
  end


  # add refresh and scanner threads 
  # TODO: move to somewhere else ( maybe computer and scanner controllers etc. )
  def start_threads
    # generate pc model shortcuts
    Main.active.clusters.each do |computers|
      computers.each { |c| Main.active.computers[c.id]=c }
    end

    # load user names from yppassed
    IO.popen("ypcat passwd").each { |line|
      names = line.split(':')
      logname = names[0]
      realname = names[4]
      Main.active.user_list.add_object([logname, realname]) 
    }
    
    prectab = Prectab.scan_file(CONFIG["prectab_path"])
    
    # refresh cache

    #@refresh_timer = Qt::Timer.new
    #@refresh_timer.connect(SIGNAL("timeout()")) {
    refresh = Thread.new {
      old_hour = 0
      session[:old_timestamp] = 0

      while true
        puts "refresh start"

        Main.active.printers.each { |p| p.update_job_count; p.update_accepts; p.update_enabled }
        hour = Time.now.hour
        if hour != old_hour
          Main.active.computers.each_value {|computer| computer.prectab = nil }
          old_hour = hour
          Debug.log.debug "prectab", prectab[hour].inspect
          if prectab[hour] then
            prectab[hour].each_pair do |kurs, daten|
              count, ort = daten[0].to_i, daten[1]   
              index = 0
              while count > 0
                c_i = CONFIG["clients"][ort][index]
                computer = Main.active.computers[c_i]
                if computer and computer.prectab == nil then
                  computer.prectab = kurs 
                  count -= 1
                end
                count -= 1 unless computer
                index += 1
              end
            end
          end
        end
        Main.active.clusters.each { |c| Computer.reload(c) }
        #comps =  Computer.updated_after @old_timestamp
        #comps.each do |computer| 
        #  eval "puts @#{computer.id}.background=code_to_color(computer.Color,computer) if  "
        #end
        
        session[:old_timestamp] = Time.now.strftime("%j%H%M%S")
        puts "refresh end"
        sleep 20
      end  
    }
    #@refresh_timer.timeout
    #@refresh_timer.start(10000)

    
    # read data from scanner and dispatch
    require 'socket'
    begin
    socket = TCPSocket.new('localhost', 7887)
    rescue Errno::ECONNREFUSED
      Debug.log.error t('scanner.no_connection')
    else
      scanner = Thread.new {
        Debug.log.debug "starting scanner thread ..."
        while true
          scan = socket.recvfrom(25)
          Debug.log.debug "Scanner says #{scan}"
          type, Main.active.scan_string = check_scanner_string(scan[0])
          case type
          when :card
            accounts = User.find_accounts_by_barcode(Main.active.scan_string)
            fill_accounts(accounts)
          when :matrikel
            accounts = Account.find_accounts_by_barcode(Main.active.scan_string)
            fill_accounts(accounts)
          when :key
            pc = Main.active.computers[Main.active.scan_string]
            unless Main.active.account_list.empty?
              table_register(pc)
            else
              case pc.user
              when ""
                Main.active.status = ["#{pc.id}", "ist schon frei", "key"] 
              else
                Main.active.status = ["#{pc.user}", "von <b>#{pc.id}</b> abgemeldet", "trashcan_full"]
              end
              key_clear(pc)
            end
          else
            Debug.log.debug "#{type}, #{Main.active.scan_string}"
          end
          sleep 1
        end
     }
    end
  end
end

