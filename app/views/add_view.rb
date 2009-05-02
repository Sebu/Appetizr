
dialog "add user" do
  stack do
    label { text_observe @main, :scan_string, :filter=>:scan_string_format }
    @account_field = field { text_observe @main, :account_text }
    flow do
      button "ok", :click => :register_users
      button "cancel", :click => :close_action
    end
  end
end

