

class FluidController  < Indigo::Controller

  def show
    @list = Indigo::ObjectListStore.new(String)
    render do
      window "SimpleDemo", :width => 300 do
        tabs do
          @text = entry {
            enter do
               @list.add(@text.text)
            end
          }
          @filter_text = entry  {
            enter do
               @atable.filter do |data|
                  data  =~ Regexp.new(@filter_text.text)
               end
            end
          }        
        end          
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

