

require 'event_handle_generator'
require 'render_some_gui'
require 'command_pattern'

module Indigo
  module Controller

    include CommandPattern
    include EventHandleGenerator
    include RenderSomeGui
  
    attr_accessor :model_name
    attr_accessor :controller

    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    def initialize
      after_initialize if respond_to? :after_initialize
      @controller = self
      self
    end

    def part(name)
      require "#{name.to_s}_controller"
      controller = eval "#{name.to_s.capitalize}Controller.one"
      controller.parent = @parent
      view = controller.show
      puts "#{@parent} parent"
      view.hide
      view
    end

    def open(mode, params={})
      params = {:title=>t(:open_file)}.merge(params)
      file_dialog(mode, params)
    end

    def file_dialog(mode, params={})
      modes = {:files=>Qt::FileDialog::ExistingFiles,
               :file=>Qt::FileDialog::ExistingFile,
               :dir_file=>Qt::FileDialog::Directory,
               :dir=>Qt::FileDialog::DirectoryOnly,
               :any=>Qt::FileDialog::AnyFile}
      title = params[:title] || ""
      root = params[:root] || ""
      filter = params[:ext] || ["*.*"]
      file_mode = modes[mode]
      fdialog = Qt::FileDialog.new(nil, title, root, filter.join(";;"))
      fdialog.setFileMode(file_mode)
      fdialog.exec
      fdialog.selectedFiles
    end
    

    def t(*params)
      I18n.t(*params)
    end

    def l(*params)
      I18n.l(*params)
    end

    def undo_action(w)
      cmds.undo
    end


    module ClassMethods
      def one
        @one ||= self.new
      end
    end

  end
end


