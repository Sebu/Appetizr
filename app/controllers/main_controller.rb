

require 'user'
require 'computer'
require 'account'
require 'account_list'
require 'controller'
require 'application'
require 'main_helper'
require 'add_controller'

require 'main'

class MainController  
  include Controller
  
  attr_accessor :main_view

  def show
    @model_name = :main
    @main = Main.one
    render

    @add_controller = AddController.one.show
  end


  def user_list_format(a)
    a.tr(" ","\n")
  end

  def drag_users(pc)
    [pc.User,pc.Color]
  end

  def drop_pool(*args)
    @pool_store = args
  end

  def drag_pool()
    @pool_store
  end

  def drop_free(user, color)
  end

  def drop_users(pc, user, color)
    old_user, old_color = pc.User, pc.Color
    command do
      pc.User=user
      pc.Color=color
      pc.save!
    end.un do
      pc.User = old_user
      pc.Color = old_color
      pc.save!
    end.run

  end


  def undo_action(w)
    super(w)
    @files = open :files
    puts @files
  end

  def code_to_color(code)
    CONFIG["colors"][code]
  end

  def cbutton_click(w, pc)
    if @test_table.model
      key_register(pc)
    end
  end

  def key_register(pc)
    old_user, old_color = pc.User, pc.Color
    old_model = @test_table.model
    command do
      new_users = []
      @test_table.model.rows.collect { |a| new_users << a.account } if @test_table.model
      pc.Color = 1
      pc.User = new_users.join(" ")
      pc.save!
      @test_table.model = nil
    end.un do
      pc.Color = old_color
      pc.User = old_user
      pc.save!
      @test_table.model = old_model
    end.run

  end

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
  end

  def fill_accounts(accounts)
    @test_table.model = accounts.length > 0 ? AccountList.new(accounts, ["account","locked"]) : @test_table.model = nil
  end

  def feld1_return(w)
#   Base.log.debug "creating model for :test_table #{@main.account_text}"
    users = @main.account_text.split(',').each { |n| n.strip! }
    accounts =  Account.find_accounts(users) # User.find_accounts_by_barcodes(users) #
    fill_accounts(accounts)
  end




  def after_initialize
    require 'socket'
    begin
    socket = TCPSocket.new('localhost', 7887)

    rescue Errno::ECONNREFUSED
      Base.log.error t('scanner.no_connection')
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

