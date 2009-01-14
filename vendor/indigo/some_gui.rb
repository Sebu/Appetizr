
module Indigo
  module SomeGui
    autoload :Create, 'indigo/some_gui/create_some_gui'
    autoload :Render, 'indigo/some_gui/render_some_gui'
    autoload :CreatesWidgets, 'indigo/some_gui/create_some_gui'
    autoload :Widgets, 'indigo/some_gui/widgets'
    autoload :Qt4Backend, 'indigo/some_gui/platform/qt4_backend'
    autoload :ClutterBackend, 'indigo/some_gui/platform/clutter_backend'
    autoload :Overlay, 'indigo/some_gui/platform/overlay'

  end
end
