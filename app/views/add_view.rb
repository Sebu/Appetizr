
dialog "add user", :width => 400, :height => 400 do
  stack do
    label { text_observe @main, :scan_string, :filter=>:scan_string_format }
    field { enter :field_return }
  end
end

