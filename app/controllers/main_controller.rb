

class MainController 
  include Indigo::Controller
  
  attr_accessor :main_view


  #TODO: remove and implicit generate in dnd functions
  def drag_pool_store
    @pool_store
  end

  def drop_pool_store(*args)
    @pool_store = *args
    @main.status = ["#{@pool_store['User']}", "von <b>#{@pool_store['Cname']}</b> in store verschoben","trashcan_full"]
  end

  def user_list_format(a)
    a.tr(" ","\n")
  end
  
  def status_format(status)
    time = Time.now.strftime("%H:%M:%S")
    title,body,icon = status
    "[#{time}] <b>#{title}</b> #{body}"
    #"[#{time}] <img src=#{Res[icon]} height=24> <b>#{title}</b> #{body}"
  end


  def code_to_color(code)
    CONFIG['colors'][code]
  end


  def cbutton_click(w, pc)
    if @account_table.model
      table_register(pc)
    end
  end

  
  
  def add_users(w)
    @add_window ||= part :add
    @add_window.show_all
  end
  
  
  def remove_users(w)
    accounts = @account_table.selection
    accounts.each { |account| Account.delete_all("barcode='#{account.barcode}' AND account='#{account.account}'") }
    account_string = accounts.collect { |a| a.account }.join(", ")
    @main.status = ["#{account_string}", "von Barcode: #{@main.scan_string} enfernt","trashcan_full"]
    #fill_accounts(@account_table.model.rows.remove(users))    
  end
  
  
  def table_register(pc)
    new_users = @account_table.model.rows.collect { |a| a.account } if @account_table.model
    users_register(new_users, pc)
    @account_table.model = nil
  end
  
  

    
  # TODO: merge with users_register methods
  def key_clear(pc)
    old_user, old_color = pc.User, pc.Color
    command do
      pc.User = ""
      pc.Color = 0
      pc.save!
    end.un do
      pc.User = old_user
      pc.Color  = old_color
      pc.save!
    end.run
    commands_end
  end

  def users_register(users, pc)
    old_user, old_color = pc.User, pc.Color
    command do
      pc.User = (pc.User.split(" ") | (users)).join(" ")
      pc.Color = CONFIG['color_mapping'][ Account.gen_color(users) ]
      pc.save!
      @main.status = ["#{pc.User}", "auf <b>#{pc.Cname}</b> angemeldet", "key"]
    end.un do
      pc.User = old_user
      pc.Color = old_color
      pc.save!
    end.run
  end

  def drop_users(pc, other_pc)
    old_user, old_color = pc.User, pc.Color
    commands_begin
    command do
      pc.User=other_pc["User"]
      pc.Color=other_pc["Color"]
      pc.save!
      @main.status = ["#{pc.User}", "von <b>#{other_pc['Cname']}</b> auf <b>#{pc.Cname}</b> verschoben","redo"]
    end.un do
      pc.User = old_user
      pc.Color = old_color
      pc.save!
      @main.status = ["#{pc.User}", "von <b>#{pc.Cname}</b> auf <b>#{other_pc['Cname']}</b> verschoben","undo"]
    end.run
  end




  def fill_accounts(accounts)
    message = ""
    accounts.each do |account|
      exists = Computer.find(:all, :select=>"Cname", :conditions=> ["User LIKE ?", "%#{account.account}%"])
      exists_string = exists.collect { |pc| pc.Cname }.join(", ")
      message +="<b>#{account.account}</b> auf <b>#{exists_string}</b>\n" unless exists.empty?
    end
    
    account_string = accounts.collect { |a| a.account }.join(", ")
    if not accounts or accounts.empty?
      @main.status = ["#{@main.scan_string}", "hat keinen Account", "barcode"]
    elsif not message == ""
      @main.status = ["#{account_string}", "#{t("account.scanned")}\n\n#{message}", "important"]
    else
      @main.status = ["#{account_string}", t("account.scanned"), "barcode"] 
    end
    @account_table.model = accounts.length > 0 ? AccountList.new(accounts, ["account","locked"]) : @account_table.model = nil
    # workaround: otherwise the GC loses @mode_table.model reference and detroys the model
    @tmp_model = @account_table.model
  end


  def account_return(w)
    direct_login = []
    users = []
    @main.account_text.split(',').each do  |n| 
      n.strip!
      case n
      when /.*@[0-9]{2,3}$/ 
        direct_login << n.split("@")
      else
        users << n
      end
    end
    accounts =  users.empty? ? [] : Account.find_accounts(users)
    accounts.collect! { |account| account.is_private? ? Account.find_accounts(account.barcode) : account } if accounts
    accounts.flatten! if accounts
    fill_accounts(accounts)
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
  def after_initialize
  
    # generate pc model shortcuts
    @main.clusters.each do |computers|
      computers.each { |c| name c, "#{c.Cname}_model" }
    end


    # load user names from yppassed
    users = []
    IO.popen("ypcat passwd").each { |line| users << line.split(':')[0] }
    @main.user_list = users
    

    # refresh cache
    refresh = Thread.new {
      while true
        sleep 20
        @main.clusters.each { |c| Computer.reload(c) }
      end  
    }

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
          type, @main.scan_string = check_scanner_string(scan[0])
          case type
          when :card
            accounts = User.find_accounts_by_barcode(@main.scan_string)
            fill_accounts(accounts)
          when :matrikel
            accounts = Account.find_accounts_by_barcode(@main.scan_string)
            fill_accounts(accounts)
          when :key
            pc = eval "@#{@main.scan_string}_model"
            if @account_table.model
              table_register(pc)
            else
              case pc.User
              when ""
                @main.status = ["#{pc.Cname}", "ist schon frei", "key"] 
              else
                @main.status = ["#{pc.User}", "von <b>#{pc.Cname}</b> abgemeldet", "trashcan_full"]
              end

              key_clear(pc)
            end
          else
            Debug.log.debug "#{type}, #{@main.scan_string}"
          end
          sleep 1
        end
     }
    end
  end
end

