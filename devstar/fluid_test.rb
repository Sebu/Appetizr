
require 'rubygems'
require 'qtext'
require 'qtwebkit'


class ColdPage < Qt::WebPage
  def initialize
    super
    settings.setAttribute(3, true)
  end
  def createPlugin(classid, url, param_names, param_values)
    puts classid
    p url 
    p param_names
    widget = Qt::PushButton.new
    widget.connect(SIGNAL(:clicked)) { puts "BLA" }
    widget 
  end
end

a = Qt::Application.new(ARGV)
view = Qt::WebView.new
view.setPage(ColdPage.new)
view.html = '<html>
   <head>
      <title>QtWebKit Plug-in Test</title>
   </head>
   <body>
      <object type="application/x-qt-plugin" classid="PushButton" name="button" width=100 height=100></object>
      <script>
        button.text="bla";
      </script>
      <object type="application/x-qt-plugin" classid="PushButton"></object>
   </body>
</html>'
view.show
a.exec
