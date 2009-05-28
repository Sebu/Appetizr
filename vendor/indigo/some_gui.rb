
module Indigo
  module SomeGui
    autoload :Create, 'indigo/some_gui/create_some_gui'
    autoload :Render, 'indigo/some_gui/render_some_gui'
    autoload :View, 'indigo/some_gui/view'
    autoload :Widgets, 'indigo/some_gui/widgets'
    autoload :GtkBackend, 'indigo/some_gui/platform/gtk_backend'
  end
end

