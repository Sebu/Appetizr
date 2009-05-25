

window t('main.title') do

  menu "demo" do
    action :quit, "/close"
  end
  statusbar
  status_observe @main, :scan_string
  
  # TODO: not the best place :)
  notification { message_observe @main, :status }
  
  stack do
    drop :drop_pool_store
    drag :drag_pool_store
    flow  :spacing => 1 do 
      @main.clusters[0..4].each { |c| render "cluster", :cluster => c }
      stack do
        @main.printers.each do | printer| 
          flow do
            label("#{printer.name}"){ background_observe printer, :accepts, :filter=>:color_please }
            label { 
              text_observe printer, :job_count
              background_observe printer, :enabled, :filter=>:color_please
            }
          end
        end
        stretch
      end
      @main.clusters[5..9].each { |c| render "cluster", :cluster => c }
    end
    stretch 
    flow do
      stack do
        field @main.account_text do |f|
          completion_observe @main, :user_list
          @main.account_text_observe f, :text
          enter :account_return
        end
        flow do
          button :undo, :click => "/undo"
          button :add, :click => "/adds/1"
        end
        @account_table = table :height => 300 do
          self.model= @main.account_list
          #columns_from_model
          column 0, "Account", :string
          column 2, "Barcode", :string
          column 1, "gelockt?", :boolean, true
          drop :drop_users_on_table
          menu :context do
            action "add users", "/adds/1"
            action "remove users", '/remove_user'
          end
        end
      end

      tabs :opacity=>0.7 do
        #add "Log", 
        table (:width => 250) do
          column 0, "Time", :string
          column 1, "Message", :string
        end
        #add "Log", text(:width => 250) { text_observe @main, :status, :filter=>:status_format }
      end
#     stretch
      stack do       
        @main.clusters[10..15].each { |c| render "cluster_h", :cluster => c }
      end
    end
  end
  
end

