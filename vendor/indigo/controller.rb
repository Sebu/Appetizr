

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
    attr_accessor :widgets
    attr_accessor :controller

    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    def initialize
      @widgets = {}
      @controller = self
      @model_name = self.class.to_s[0..-11] 
      after_initialize if respond_to? :after_initialize
      self
    end


    def load_context
      @parent = render
    end
    
    def show
      eval "@#{model_name.downcase} = #{model_name}.active"
      #TODO: put into perform_action
      view = load_context
      view.show_all
      view
    end
    
    def perform_action(action, *args)
      send(action, *args)
    end
  
    def redirect_to(uri, *args)
      data = /(\/([a-z_]+)s)?(\/([a-z_]+))?(\/(\d+))?$/.match(uri)
      controller_name = data[2] ? "#{data[2].capitalize}Controller" : self.class.name
      action = data[4] || "show"
      id = data[6]
      Debug.log.debug "#{controller_name} #{action} #{id}"
      new_controller = Kernel.const_get(controller_name).one
      new_controller.parent = @parent 
      new_controller.perform_action(action, *args)
    end
    
    # /model/action/id 
    def self.redirect_to(uri)
             
      data = /(\/([a-z_]+)s)?(\/([a-z_]+))?(\/(\d+))?$/.match(uri)
      #Debug.log.debug
      controller_name = "#{data[2].capitalize}Controller"
      action = data[4] || "show"
      id = data[5]
      puts controller_name, action, id
      new_controller = Kernel.const_get(controller_name).one
      new_controller.parent = @parent 
      new_controller.perform_action(action)
    end
    
    def open(mode, params={})
      params = {:title=>t(:open_files)}.merge(params)
      file_dialog(mode, params)
    end


    def confirm(text, params={})
      box = Qt::MessageBox.new @parent.widget
      box.text = text
      box.window_title="Are you sure?"
      box.icon = Qt::MessageBox::Question
      box.informative_text = params[:info] || nil
      box.detailed_text = params[:details] || nil
      box.standard_buttons= Qt::MessageBox::No|Qt::MessageBox::Yes
      value = box.exec
      value == Qt::MessageBox::Yes or value == Qt::MessageBox::Ok
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

    #region: actions

    def close
      eval "@#{model_name.downcase}_view.hide"
    end

    module ClassMethods
      def one
        @one ||= self.new
      end
    end

  end
end


