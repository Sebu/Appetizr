

window t('main.title'),  :opacity=>0.7  do
  
  # TODO: not the best place :)

  notification { message_observe @main, :status }
  
  stack do
    drop :drop_pool_store
    drag_start :drag_pool_store
    flow  :spacing => 1 do 
      @main.clusters[0..9].each { |c| render "cluster", :cluster => c }
    end
    stretch 
    flow do
      stack do
        field @main.account_text do
          completion_observe @main, :user_list
          @main.account_text_observe @parent, :text
          enter :account_return
        end
        flow do
          button "undo", :click => :undo_action
          button "add", :click => :add_users
        end
        @account_table = table do
          drop :drop_users_on_table
          column 1, :CheckBox
          menu "context" do
            action "add users", :add_users
            action "remove users", :remove_users
          end
        end
      end

      tabs :opacity=>0.7 do
        add "L&og", text { text_observe @main, :status, :filter=>:status_format }
      end
#     stretch
      stack do       
        @main.clusters[10..15].each { |c| render "cluster_h", :cluster => c }
      end
    end
  end
end

