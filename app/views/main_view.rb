

window t('main.title') do

  menu "other" do
    action :refresh, "/refresh_cache"
    action :quit, "/close"
  end
  
  menu :context do
    action :undo, "/undo"
    action "send text", "/send_text"

  end

  trayicon t('main.title') do
    menu :context do
      action :present, "/present"
    end
  end
  
  statusbar
  status_observe @main, :scan_string
  
  # TODO: not the best place :)
  notification { message_observe @main, :status }

  drop :drop_pool_store
  drag :drag_pool_store
      
  stack {
    flow  :spacing => 1 do 
      @main.clusters[0..4].each { |c| render "cluster", :cluster => c }
      stack {
        @main.printers.each do |printer| 
          flow {
            box {
              background_observe printer, :accepts do |state| color_please(state) end
              label "#{printer.name}" 
            }
            box(:width=>100) {
              background_observe printer, :enabled do |state| color_please(state) end
              label { text_observe printer, :job_count }
            }
          }
        end
        stretch
      }
      @main.clusters[5..9].each { |c| render "cluster", :cluster => c }
    end
    stretch 
    flow {
      stack {
        field @main.account_text do
          completion_observe @main, :user_list
          @main.account_text_observe self, :text
          enter :account_return
        end
        flow {
          button :undo, :click => "/undo" #TODO: should be implicit
          button :add, :click => "/adds/1"
        }
        table :id => "account_table", :height => 350, :width=>300 do
          model @main.account_list
          columns_from_model :headers => ["Account", "Barcode","gelockt?"]
          drop :drop_users_on_table
          menu :context do
            action "add users", "/adds/1"
            action "remove users", '/remove_user'
          end
        end
      }

      tabs :width => 500 do
        table "Log" do
          model @main.status_list
          columns_from_model :headers => ["Time", "Message"]
        end
        table "Belegung" do
          column 0, "LV", String
          column 1, "Anzal", String
        end
      end
      tabs {
        stack "Westsaal" do       
          @main.clusters[10..15].each { |c| render "cluster_h", :cluster => c }
        end
        stack "Schulungsraum"
      }
    }
  }
  
end

