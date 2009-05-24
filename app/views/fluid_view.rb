

window "fluid" do
  stack do
    flow do
      button "bla1"
      button "bla2"
    end

    tabs do
      button "blub3", :click => "/undosd"
      @feld = field "hallo"
      label("test") { text_observe @feld,:text }
    end
    text ("hallo") {text_observe @feld, :text }

  end
end

