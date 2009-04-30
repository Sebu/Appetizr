

window t('main.title') do
  
  # TODO: not the best place :)
  @add_window = part :add
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
          @main.account_text_observe @parent, :text
          enter :account_return
        end
        flow do
          button "undo", :click => :undo_action
          button "add", :click => :add_user
        end
        @account_table = table do
          column 1, :CheckBox
        end
      end

      tabs :opacity=>0.7 do
        tab_title "L&og"
        text  { text_observe @main, :status, :filter=>:status_format }
      end
      stretch
      stack do       
        @main.clusters[10..15].each { |c| render "cluster_h", :cluster => c }
      end
    end
  end
end

