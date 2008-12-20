

window :text=> t('main.title') do 
    stack do
      drop :drop_free

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
        stretch
        stack do       
          @main.clusters[10..15].each { | c |
            render "cluster_h", :cluster => c
          }
        end
      end
    end
end

