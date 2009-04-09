

window t('main.title') do 
  stack do
    drop :drop_pool
    drag_start :drag_pool
    flow  :spacing => 1 do 
      @main.clusters[0..9].each { | c |
        render "cluster", :cluster => c
      }
    end
    stretch 
    flow do
      stack do
        field @main.account_text do
          @main.account_text_observe @parent, :text
          enter :feld1_return
        end
        @test_table = table do
          column 1, :CheckBox
          #column 1, :ProgressBar, :filter=>:test_filter
        end
      end
      tabs :opacity=>0.7 do
        tab_title "&TestTab"
        group "playground", :radio=>true do
          stack do
              button "undo", :click => :undo_action
              button "gl demo", :click => :click_gl_demo
              button("open files") { click :open_action, :files }

              @slider = hslider :min=> -100
              @spin = spin { value_observe @slider, :value }
              @slider.value_observe  @spin, :value     
              radio "test2"
              check "test3"
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

