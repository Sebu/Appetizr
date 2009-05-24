
dialog "add user" do
  stack do
    label { text_observe @main, :scan_string, :filter=>:scan_string_format }
    @add.account_field = field { text_observe @main, :account_text }
    flow do
      button :cancel, :click => '/close'
      button :ok, :click => '/register_user'
    end
  end
end

