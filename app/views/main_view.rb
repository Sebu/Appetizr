

# add widgets from gtkbuilder spec files
#from_builder "app/views/test.glade"

notification { message_observe @main, :status }

trayicon t('main.title') do
  menu { 
    action :present 
    action "gummibaum"
  }
end
  
window t'main.title' do
  
  menu t"menu.other" do 
    action :refresh
    separator
#   action :lock_users
    action :quit
  end
  


  menu(:id=>"menu") do 
    action :undo
    action "send text", "messages/1"
  end


  statusbar
  status_observe @main, :scan_string
  
  drop :drop_pool_store
  drag :drag_pool_store
      
  stack(:padding=>5){
    flow  :spacing => 5 do 
      render "cluster_v", :cluster => @main.clusters[15]
      @main.clusters[13..14].reverse_each { |c| render "cluster", :cluster => c }
      render "cluster", :cluster => @main.clusters[12] #TODO: own view file
      render "cluster", :cluster => @main.clusters[11] 
      stack(:height=>100, :spacing=>2) {
        @main.printers.each {|printer|render "printer", :printer => printer }
      }    
      render "cluster", :cluster => @main.clusters[10]      
      render "cluster", :cluster => @main.clusters[9]  #TODO: own view file    
      @main.clusters[7..8].reverse_each { |c| render "cluster", :cluster => c }
      render "cluster_v", :cluster => @main.clusters[6]
    end
    flow(:spacing=>3) {
      stack {
        entry do |e|
          completion_observe @main, :user_list
          @main.account_text_observe e, :text
          on :enter, :account_return
        end
        flow {
          button :undo, :click => :undo #TODO: should be implicit
          button :add, :click => "/adds/1"
        }
        table :id => "account_table", :height => 350, :width=>300 do |tbl|
          tbl.background="#FFFFFF"
          tbl.tooltip_column=5
          model @main.account_list
#         columns_from_model :headers => ["Account", t("account.locked")]
          column 3, "State", :icon, false #, :markup=>3
          column 1, "Account", String, false, :markup=>1
          column 4, "Notifies", :icon, false, :icon_name=>4
          column 2, "locked?", TrueClass, true, :active=>2
          drop :drop_users_on_table
          on(:cell_clicked) { |data, controller| update_notifies_menu(data) }
          menu do
            menu "notifies", :id=>"notifies_menu" 
            separator
            menu "card data" do
              action "add users ...", "adds/1"
              action "remove selected"
            end
          end

        end
      }

      tabs :width => 500 do
        table t("log") do
          model @main.status_list
          columns_from_model :headers => ["Time", "Message"]
          search do |data,key|
            data[1] =~ /.*#{key}/
          end          
        end
        #table t("belegung") do
        #  column 0, "LV", String
        #  column 1, "Anzal", String
        #end
      end
      tabs :position=>:bottom do
        stack t("westsaal"), :padding=>5 do       
          @main.clusters[0..5].reverse_each { |c| render "cluster_h", :cluster => c }
        end
        flow t("schulungsraum"), :padding=>5  do       
          @main.clusters[16..17].reverse_each { |c| render "cluster", :cluster => c }
        end
      end
    }
  }
  
end

