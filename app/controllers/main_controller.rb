

class MainController 
  include Indigo::Controller
  
  attr_accessor :main_view


  #TODO: remove and implicit generate in dnd functions
  def drag_pool_store
    @pool_store
  end
  def drop_pool_store(*args)
    @pool_store = *args
    @main.status = ["#{@pool_store['User']}", "von #{@pool_store['Cname']} in store verschoben","trashcan_full"]
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
    account_string = accounts.collect { |a| a.account }.join(" ")
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
      pc.Color = old_color
      pc.save!
    end.run
    commands_end
  end

  def users_register(users, pc)
    old_user, old_color = pc.User, pc.Color
    command do
      pc.User = users.join(" ")
      pc.Color = CONFIG['color_mapping'][ Account.gen_color(users) ]
      pc.save!
      @main.status = ["#{pc.User}", "auf #{pc.Cname} angemeldet", "key"]
    end.un do
      pc.User = old_user
      pc.Color = old_color
      pc.save!
    end.run
  end

  def drop_users(pc, other_pc)
    old_user, old_color = pc.User, pc.Color
    commands_end
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
    account_string = accounts.collect { |a| a.account }.join(" ")
    @main.status = ["#{account_string}", t("account.scanned"), "barcode"]
    @account_table.model = accounts.length > 0 ? AccountList.new(accounts, ["account","locked"]) : @account_table.model = nil
    # workaround: otherwise the GC loses @mode_table.model reference and detroys the model
    @tmp_model = @account_table.model
  end


  # TODO:     #direct_login = users.collect{ |u| u.split("@") } 
  def account_return(w)
    users = @main.account_text.split(',').each { |n| n.strip! }
    accounts =  Account.find_accounts(users)
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
  
    @main.clusters.each do |computers|
      computers.each {|c| name c, "#{c.Cname}_model" }
    end
    

    refresh = Thread.new {
      while true
        sleep 20
        @main.clusters.each { |c| Computer.reload(c) }
      end  
    }

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
            pc = eval "@#{data}_model"
            if @account_table.model
              table_register(pc)
            else
              @main.status = ["#{pc.User}", "von #{pc.Cname} abgemeldet", "key"]
              key_clear(pc)
            end
          else
            Debug.log.debug "#{type}, #{data}"
          end
          sleep 1
        end
     }
    end
  end
end

