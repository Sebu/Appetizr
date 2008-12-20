

require 'user'
require 'computer'
require 'account'
require 'account_list'
require 'controller'
require 'application'
require 'main_helper'

class MainController  
  include Controller

  def user_list_format(a)
    a.tr(" ","\n")
  end

  def drag_users(pc)
    [pc.User,pc.Color]
  end

  def drop_free(user, color)
  end

  def drop_users(pc, user, color)
    pc.User=user
    pc.Color=color
    pc.save!
  end

  def code_to_color(code)
    CONFIG["colors"][code]
  end

  def cbutton_click(w, pc)
    if @test_table.model
      key_register(pc)
    else 
      key_clear(pc)
    end
  end

  def key_register(pc)
    new_users = ""
    @test_table.model.rows.each { |a| new_users += "#{a.account} " } if @test_table.model
    pc.User = new_users.strip
    pc.Color = 1
    pc.save!
    @test_table.model = nil
  end

  def key_clear(pc)
    pc.User = ""
    pc.Color = 0
    pc.save!
  end

  def fill_accounts(accounts)
    @test_table.model = accounts.length > 0 ? AccountList.new(accounts, ["account","locked"]) : @test_table.model = nil
  end

  def feld1_return(w)
#   Base.log.debug "creating model for :test_table #{@main.account_text}"
    users = @main.account_text.split(',').each { |n| n.strip! }
    accounts = Account.find_accounts(users) # User.find_accounts_by_barcodes(users) #
    fill_accounts(accounts)
  end




  def after_initialize
    require 'socket'
    begin
    socket = TCPSocket.new('localhost', 7887)

    rescue Errno::ECONNREFUSED
      Base.log.error t 'scanner.no_connection'
    else
      scanner = Thread.new {
        Base.log.debug "starting scanner thread ..."
        while true
          scan = socket.recvfrom(25)
          Base.log.debug "Scanner says #{scan}"
          type, data = check_scanner_string(scan[0])
          @main.scan_string = data
          case type
          when :matrikel
            accounts = Account.find_accounts_by_barcode(data)
            fill_accounts(accounts)
          when :key
            @test_table
            pc = eval "@#{data}_model"
            if @test_table.model
              key_register(pc)
            else
              key_clear(pc)
            end
          else
            Base.log.debug "#{type}, #{data}"
          end
          sleep 1
        end
      }
    end
  end




end

