
dialog t"sendtext.title" do
  flow {
     check true, t("westsaal")
     check true, t("hauptsaal")
     check false, t("schulungsraum")
  }
  textview {
    text t("sendtext.default")
  }
  flow {
    button :cancel, :click => '/hide'
    button t("send"), :click => '/send'
  }
end

