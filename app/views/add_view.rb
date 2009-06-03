
dialog "add user" do
  label { text_observe @main, :scan_string do |string| scan_string_format(string) end }
  @add.account_field = entry { text_observe @main, :account_text }
  flow do
    button :cancel, :click => '/hide'
    button :add, :click => '/register_user'
  end
end

