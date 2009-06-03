
dialog "send message" do
  flow do
#    field @message.hauptsaal
#    field @message.schulungsraum
#    field @message.westsaal
  end
  flow do
    button :cancel, :click => '/hide'
    button :add, :click => '/register_user'
  end
end

