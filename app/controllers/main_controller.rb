
class MainController < Indigo::Controller
  helper MainHelper
  
  #after_initialize :start_threads
  
  def show
    @main = Main.active
    render.show_all
    start_threads #TODO :/
  end
  
  #TODO remove and implicit generate in dnd functions
  def drag_pool_store
    session[:pool_store]
  end

  def drop_pool_store(data)
    return unless data
    session[:pool_store] = data
    Main.active.status = ["#{session[:pool_store]['User']}", "von <b>#{session[:pool_store]['Cname']}</b> in store verschoben","trashcan_full",1]
  end

  def add_notify
    text = input
    selection = berry["account_table"].selection.to_a
    selection.each do |item|
      item.create_notify(text)
    end
    @main.account_list.update
  end
  
  def drop_users_on_table(other_pc)
    users = other_pc["User"].split(" ")
    accounts = Account.find_accounts_or_initialize(users)
    fill_accounts(accounts)
  end

  def lock_users
    `#{CONFIG['user_lock_file']}`
  end

  def remove_from_pc(pc, user)
    pc.remove_user(user)
  end
   
  def remove_selected
    selection = berry["account_table"].selection.to_a
    if !selection.empty? and confirm(t"account.ask_remove",:accounts=>selection.collect{|a|a.account}.join(", "))
      berry["account_table"].selection.remove
      account_string = selection.collect { |a| a.account }.join(", ")
      Main.active.status = ["#{account_string}", "von Barcode: #{Main.active.scan_string} enfernt","trashcan_full",1]
    end
  end
  

  def table_register(pc)
    return if Main.active.account_list.empty?
    new_users = berry["account_table"].selection.to_a.collect { |a| a.account } unless Main.active.account_list.empty?
    users_register(new_users, pc)
    Main.active.account_list.clear
    
  end
  
  

    
  # TODO: merge with users_register methods
  def key_clear(pc)
    old_user = pc.user
    command("key clear") do
      pc.user = ""
      pc.save!
    end.un do
      pc.user = old_user
      pc.save!
    end.run
    commands_end
  end

  def users_register(users, pc)
    return if users.empty?
    
    old_user = pc.user
    command("register users") do
      pc.user = users.join(" ") #(pc.User.split(" ") | (users)).join(" ")
      pc.save!
      Main.active.status = ["#{pc.user}", "auf <b>#{pc.id}</b> angemeldet", "chair",1]
    end.un do
      pc.user = old_user
      pc.save!
    end.run
    end

  def drop_user(pc, other_pc)
    #pc = Computer.find(pc_id.id)
    return false if !other_pc or other_pc["User"]==""
    old_user = pc.user
    commands_begin "dnd user"
    command("drop users") do
      pc.user=other_pc["User"]
      pc.save!
      Main.active.status = ["#{pc.user}", "von <b>#{other_pc['Cname']}</b> auf <b>#{pc.id}</b> verschoben","redo",0]
    end.un do
      pc.user = old_user
      pc.save!
      Main.active.status = ["#{pc.user}", "von <b>#{pc.id}</b> auf <b>#{other_pc['Cname']}</b> verschoben","undo",0]
    end.run
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
      Main.active.status = ["#{Main.active.scan_string}", "hat keinen Account", "barcode",-1]
    elsif not message == ""
      Main.active.status = ["#{account_string}", "#{t("account.scanned")}\n\n#{message}", "important",-1]
    else
      Main.active.status = ["#{account_string}", t("account.scanned"), "barcode", 1] 
    end
    Main.active.account_list.clear
    Main.active.account_list += accounts
    berry["account_table"].select_all
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
      when /^.{1,8}$/
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
      Main.active.status = ["#{users}", "existiert nicht", "important", -1]
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
      return :matrikel, scan.chomp!
    end
  end
  

  def scatter_prectab(prectab, timeslot)
    prectab.each_pair do |kurs, daten|
      count, ort = daten[0].to_i, daten[1]   
      index = 0
      liste = CONFIG["clients"][ort]
      liste = case kurs
      when "itf","itc" then CONFIG["clients"][ort].reverse
      else CONFIG["clients"][ort]
      end
      while count > 0
        c_i = liste[index]
        computer = Main.active.computers_cache[c_i]
        if computer and computer.prectab[timeslot] == nil and !computer.user.include?("nobody") then
          computer.prectab[timeslot] = kurs 
          count -= 1
          computer.prectab_changed
          computer.color_changed
          computer.user_changed
        end
        count -= 1 unless computer
        index += 1
      end
    end
  end  
  
  def refresh
    session[:old_timestamp] = 0
  end

  # add refresh and scanner threads 
  # TODO: move to somewhere else ( maybe computer and scanner controllers etc. )
  def start_threads
  
    # generate computers cache model shortcuts
    Main.active.clusters.each do |computers|
      computers.each { |c| Main.active.computers_cache[c.id]=c }
    end

    # load user names from yppassed
    IO.popen("ypcat passwd").each { |line|
      Main.active.user_list.add(line.split(":").values_at(0, 4)) 
    }
    
    
    refresh = Thread.new {
      session[:old_timestamp] = 0

      while true
        puts "refresh start"

       
        # update prectab data
        if Prectab.changed?
          Main.active.computers_cache.each_value {|computer| computer.prectab = [nil,nil]; computer.color_changed; computer.user_changed }
          Debug.log.debug "working prectab"
          scatter_prectab(Prectab.now,0)
          scatter_prectab(Prectab.soon,1)
        end

        # update computers_cache
        comps =  Computer.updated_after session[:old_timestamp]
        comps.each do |computer| 
          cache_computer = Main.active.computers_cache[computer.id]
          if cache_computer
            cache_computer.User = computer.user 
            cache_computer.Color = computer.color
          end
        end
        session[:old_timestamp] = Time.now.strftime("%j%H%M%S")


        # update printers
        Main.active.printers.each { |p| p.update_job_count; p.update_accepts; p.update_snmp }

        puts "refresh end"
        sleep 20
      end  
    }

    
    # read data from scanner and dispatch
    require 'socket'
    begin
    socket = TCPSocket.new('localhost', 7887)
    rescue Errno::ECONNREFUSED
      Main.active.status = ["Scanner", t('scanner.no_connection'), "important",-1]
    else
      scanner = Thread.new {
        Debug.log.debug "starting scanner thread ..."
        while true
          scan = socket.recvfrom(25)
          type, Main.active.scan_string = check_scanner_string(scan[0])
          Debug.log.debug "Scanner says #{scan} #{type}, #{Main.active.scan_string}"
          case type
          when :card
            accounts = User.find_accounts_by_barcode(Main.active.scan_string)
            fill_accounts(accounts)
          when :matrikel
            accounts = Account.find_accounts_by_barcode(Main.active.scan_string)
            fill_accounts(accounts)
          when :key
            pc = Main.active.computers_cache[Main.active.scan_string]
            puts pc
            unless Main.active.account_list.empty?
              table_register(pc)
            else
              case pc.user
              when ""
                Main.active.status = ["#{pc.id}", "ist schon frei", "key",0] 
              else
                Main.active.status = ["#{pc.user}", "von <b>#{pc.id}</b> abgemeldet", "trashcan_full",1]
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

