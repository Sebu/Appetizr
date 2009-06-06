

# add widgets from gtkbuilder spec files
#from_builder "app/views/test.glade"


# TODO: not the best place :)
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
  
  # menu :context do  # :context is now default 
  menu :id=>"menu" do 
    action :undo
    action "send text", "messages/1"
  end


  statusbar
  status_observe @main, :scan_string
  


  drop :drop_pool_store
  drag :drag_pool_store
      
  stack {
    flow  :spacing => 1 do 
      render "cluster_v", :cluster => @main.clusters[15]
      @main.clusters[11..14].reverse_each { |c| render "cluster", :cluster => c }
      stack {
        @main.printers.each do |printer| 
          flow {
            click do gen_printer_menu(printer) end #TODO do some auto updating here  
            menu :id=>"#{printer.name}_menu"
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
      }
      @main.clusters[7..10].reverse_each { |c| render "cluster", :cluster => c }
      render "cluster_v", :cluster => @main.clusters[6]
    end
    flow {
      stack {
        entry do |e|
          completion_observe @main, :user_list
          @main.account_text_observe e, :text
          enter :account_return
        end
        flow {
          button :undo, :click => :undo #TODO: should be implicit
          button :add, :click => "/adds/1"
        }
        table :id => "account_table", :height => 350, :width=>300 do
          model @main.account_list
          columns_from_model :headers => ["Account", t("account.locked")]
          drop :drop_users_on_table
          menu :context do
            action "add users", "adds/1"
            action "remove user"
          end
        end
      }

      tabs :width => 500 do
        table t"log" do
          model @main.status_list
          columns_from_model :headers => ["Time", "Message"]
          search do |data,key|
            data[1] =~ /.*#{key}/
          end          
        end
        table t"belegung" do
          column 0, "LV", String
          column 1, "Anzal", String
        end
      end
      tabs :position=>:bottom do
        stack t"westsaal" do       
          @main.clusters[0..5].reverse_each { |c| render "cluster_h", :cluster => c }
        end
        stack t"schulungsraum"
      end
    }
  }
  
end

