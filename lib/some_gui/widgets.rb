
module Indigo
module SomeGui
  autoload :Qt4Backend, 'some_gui/platform/qt4_backend'

module Widgets
  include Indigo::SomeGui::Qt4Backend
end

end
end
