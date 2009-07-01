
dialog "blaaa" do
  textview {
    text "bla"
  }
  flow {
    button :cancel, :click => '/hide'
    button t"send", :click => '/send'
  }
end

