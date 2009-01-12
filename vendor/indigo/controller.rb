

FileModes = {:files=>Qt::FileDialog::ExistingFiles,
               :file=>Qt::FileDialog::ExistingFile,
               :dir_file=>Qt::FileDialog::Directory,
               :dir=>Qt::FileDialog::DirectoryOnly,
               :any=>Qt::FileDialog::AnyFile}

module Indigo
  module Controller
    include CommandPattern
    include EventHandleGenerator
    include SomeGui::Create
    include SomeGui::Render

 
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
      require "#{name.to_s}_helper"
      require "#{name.to_s}"

      controller = eval "#{name.to_s.capitalize}Controller.one"
      controller.parent = @parent
      view = controller.show
      #puts "#{@parent} parent"
      #puts @parent.widget
      view.hide
      view
    end

    def open(mode, params={})
      params = {:title=>t(:open_files)}.merge(params)
      file_dialog(mode, params)
    end

    def file_dialog(mode, params={})
      title  = params[:title] || ""
      root   = params[:root]  || ""
      filter = params[:ext]   || ["*.*"]
      file_mode = FileModes[mode]
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


