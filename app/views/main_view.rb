

window :text=> t('main.title') do 
  stack do
    drop :drop_pool
    drag_start :drag_pool
    flow :spacing => 1 do 
      @main.clusters[0..9].each { | c |
        render "cluster", :cluster => c
      }
    end
    stretch 
    flow do
      stack do
        field(:text => @main.account_text) {
          @main.account_text_observe @parent, :text
          enter :feld1_return
        }
        @test_table = table
      end
      tabs do
        tab_title "&TestTab"
        group :text=>"playground", :radio=>true do
          stack do
              button :text => "undo", :click => :undo_action
              radio :text => "test1"
              radio :text => "test2"
              @slider = hslider :min=> -100
              @spin = spin { value_observe @slider, :value }
              @slider.value_observe  @spin, :value     
              check :text => "test3"
              stretch
          end
        end
        tab_title "L&og"
        table
      end
      stretch
      stack do       
        @main.clusters[10..15].each { | c |
          render "cluster_h", :cluster => c
        }
      end
    end
  end
end

