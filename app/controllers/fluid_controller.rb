

class FluidController  < Indigo::Controller

  def show
    @fluid = Fluid.active
    @list = Indigo::ObjectListStore.new(String)
    render do
      window "SimpleDemo", :width => 300 do
        @text = entry {
          enter do
              @list.add(@text.text)
          end
        }
        @filter_text = entry {
          enter do
              @atable.filter do |data|
                data  =~ Regexp.new(@filter_text.text)
              end
          end
        }        
        
        field @fluid, :name
        check false, "test"
        
        @atable = table(:height => 400) {
          model @list
          columns_from_model :headers => ["Texteingaben"]
          search do |data, key|
            data == key
          end
        }
      end
    end.show_all
  end


end

