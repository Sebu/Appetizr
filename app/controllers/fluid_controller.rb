

class FluidController  < Indigo::Controller
  def show

    @fluid = Fluid.active
    @list = Indigo::ObjectListStore.new(String)
    
    render {
      from_file "test.glade"
      
      update "testbutton" do
        on(:click) { puts "hallo" }
      end
      
      update "hull" do
        @text = entry {
          on :enter do
              @list.add(@text.text)
          end
        }
        @filter_text = entry {
          on :enter do
            @atable.filter do |data|
              data  =~ Regexp.new(@filter_text.text)
            end
          end
        }        
        
        check false, "test"
        @r1 = radio false, "test"
        radio true, "test2", @r1
        
        @atable = table(:height => 400) {
          model @list
          columns_from_model :headers => ["Texteingaben"]
          search do |data, key|
            data == key
          end
        }
      end 
      show_all     
    }
    

  end
end

