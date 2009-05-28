
dialog "add user" do
  stack do
    label { text_observe @main, :scan_string do |string| scan_string_format(string) end }
    @add.account_field = field { text_observe @main, :account_text }
    flow do
      button :cancel, :click => '/close'
      button :add, :click => '/register_user'
    end
  end
end

