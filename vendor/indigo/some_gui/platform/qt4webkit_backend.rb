

require 'qtwebkit'
module Indigo
module SomeGui
module Qt4WebkitBackend

class ColdPage < Qt::WebPage
  def initialize(v, controller)
    super(v)
    @controller = controller
    settings.setAttribute(3, true)
  end
  def createPlugin(classid, url, param_names, param_values)
    @controller.widgets[classid.to_s].widget
  end
end

  module QtWidget
    include Widget

    attr_accessor :widget

    def qt_class_name
      @widget.class.name.sub("Qt::","Q")
    end

    def background=(value)
      @widget.setStyleSheet("#{qt_class_name} { background-color:  #{value} }")
    end

    def status_tip=(value)
      @widget.status_tip=value
    end

    def tool_tip=(value)
      @widget.tool_tip=value
    end

    def add(w)
      add_element(w)
    end

    def respond
      "<object type='application/x-qt-plugin' classid='#{self.object_id}' width='#{self.widget.sizeHint.width}'></object>"
    end    

    def parse_params(params)
      @widget.windowOpacity =  params[:opacity] || 1.0
    end

    def drop(method, *args)
      controller = @controller
      
      @widget.accept_drops = true
      @widget.instance_eval %{

        @dnd_drop_args = args
        @dnd_drop_method = method
        @controller = controller

        def simple_accept(event)
          action = if event.keyboardModifiers == Qt::ControlModifier
                      Qt::CopyAction
                    else
                      Qt::MoveAction
                    end 
          event.setDropAction(action)
          event.accept
        end

        def dragEnterEvent(event)
          simple_accept(event)
        end

        def dragMoveEvent(event)
          simple_accept(event)
        end

        def dropEvent(event)
          incomming = event.mimeData.text 
          data = ActiveSupport::JSON.decode(incomming)
          @controller.send(@dnd_drop_method,*(@dnd_drop_args+[data])) unless self == event.source
          simple_accept(event) 
        end
      }
    end

    def drag_delete(method)
      @widget.instance_eval %{
        @dnd_drag_delete_method = method
      }
    end

    def drag_start(method, *args)
        controller = @controller
        @widget.instance_eval %{

        @controller = controller
        @dnd_drag_args = args
        @dnd_drag_method = method

        def mousePressEvent(event)
           super
           if (event.button == Qt::LeftButton)
             @dragStartPosition = event.pos
           end
        end

        def mouseMoveEvent(event)
           super
           return if @drag_in_progress || false
           return if (event.buttons != Qt::LeftButton)
           return if ((event.pos - @dragStartPosition).manhattanLength < Qt::Application::startDragDistance)
           if @dnd_drag_method == :direct
             data = *@dnd_drag_args
           else
             data = @controller.send(@dnd_drag_method,*@dnd_drag_args)
           end
           return unless data 
           @drag_in_progress = true    

           drag = Qt::Drag.new(self)
           mimeData = Qt::MimeData.new
          
           mimeData.setText(data.to_json)
           drag.setMimeData(mimeData)

           
           dropAction = drag.exec(Qt::CopyAction | Qt::MoveAction)
           if (@dnd_drag_delete_method and dropAction == Qt::MoveAction and drag.source != drag.target)
             @controller.send(@dnd_drag_delete_method, *@dnd_drag_args)
           end
           @drag_in_progress = false
        end
        }

    end

  end

  class Window 
    include QtWidget
    include ObserveAttr
    observe_attr :text

    def initialize(p, name)
      @widget = Qt::MainWindow.new(nil)
      @view = Qt::WebView.new
      @view.setPage(ColdPage.new(@view,p.controller))
      @widget.setCentralWidget(@view)
      self.text=name
      @html = ""
    end

    def statusbar
      @widget.statusBar
    end

    def parse_params(params)
      posx = params[:posx] || 100 
      posy = params[:posy] || 100
      width = params[:width]
      height = params[:height] 
      @widget.setGeometry(posx, posy, width, height) if width and height
      super
    end

    def respond
      self
    end    

    def text=(value) 
      @widget.setWindowTitle(value)
    end
    def text
      @widget.windowTitle
    end

    
    def add_element(w)
      @html += w.respond          
      puts @html
    end

    def show_all
      super
      @view.html = @html
      @widget.show
    end
    def hide
      @widget.hide
    end
  end


  class Dock
    include QtWidget

    def initialize(p, title)
      @widget = Qt::DockWidget.new(title, p.widget)
      p.add_element(self)
    end
  
    def add_element(w)
      @widget.setWidget(w)
    end

  end

    
  class Dialog 
    include QtWidget
    include ObserveAttr
    observe_attr :text

    def initialize(p, title)
      @widget = Qt::Dialog.new(p.widget) #, Qt::CustomizeWindowHint | Qt::WindowTitleHint)
      @layout = Qt::HBoxLayout.new
      @widget.setLayout(@layout)
      self.text=title
    end

    def parse_params(params)
      #puts "#{params[:text]}"
      #posx = params[:posx] || 100 
      #posy = params[:posy] || 100
      width = params[:width]
      height = params[:height] 
      @widget.setMinimumWidth(width) if width
      @widget.setMinimumHeight(height) if height
      #Geometry(posx, posy, width, height) if width and height
      super
    end

    def text=(value) 
      @widget.setWindowTitle(value)
    end
    def text
      @widget.windowTitle
    end


    def add_element(w)
      @widget.layout.addWidget(w.widget)
    end
    def show_all
      @widget.show
    end
    def hide
      @widget.hide
    end
  end

 
  class GlArea
    include QtWidget
    include ObserveAttr

#   obsattr_reader :update, :func => :gl_update

    def initialize(p)
      @widget = Qt::GraphicsView.new(p.widget)
      @scene = Qt::GraphicsScene.new
      @widget.setViewport( Qt::GLWidget.new )
      @widget.setViewportUpdateMode(Qt::GraphicsView::FullViewportUpdate)
      @widget.setScene(@scene)
      p.add_element(self)
      @widget.show
    end
    def gl_update(*args)
      @widget.update
      Qt::Timer::singleShot(20, @widget, SLOT("update()"))
    end
    def add_element(w)
      @scene.addWidget(w.widget)
    end
    def parse_params(params)
      outter = self
      controller = @controller
      resize = params[:resize] || :gl_resize
      draw = params[:draw] || :gl_draw
      gl_init = params[:init] || :gl_init

      @widget.instance_eval do
        @outter = outter
        @controller = controller
        @resize_method = resize
        @draw_method = draw
        @init_method = gl_init

        def resizeEvent(event) 
            if (scene)
                scene.sceneRect =  Qt::Rect.new(Qt::Point.new(0, 0), event.size) 
            end
            super
        end

        def after_initialize
            pos = Qt::PointF.new(10, 10)
            items.each do | item |
                item.setFlag(Qt::GraphicsItem::ItemIsMovable)
                item.setCacheMode(Qt::GraphicsItem::DeviceCoordinateCache)
                rect = item.boundingRect
                item.setPos(pos.x - rect.x, pos.y - rect.y)
                pos += Qt::PointF.new(0, 10 + rect.height)
            end
        end

        def drawBackground(painter, rect)
            @controller.send(@init_method)
            #@controller.send(@resize_method , width, height)
            @controller.send(@draw_method)
            update
        end
    
        def initializeGL
          @controller.send(@init_method)          
        end
        def paintGL
          @controller.send(@draw_method)
        end
        def resizeGL(w, h)
          @controller.send(@resize_method , w, h)
        end
      end
      @widget.after_initialize
      super
    end
  end

=begin
  class CheckBoxD < Qt::ItemDelegate
    attr_accessor :filter_func, :controller

    def createEditor(parent, item, index) 
      box = Qt::CheckBox.new(parent)
      connect(box, SIGNAL("stateChanged(int)")) { emit commitData(box) }
      box
    end

    def setEditorData(editor, index)
      puts index.column
      value = index.model.data(index, Qt::DisplayRole).toBool
      editor.setCheckState( value ? Qt::Checked : Qt::Unchecked )
    end
 
    def setModelData(editor, model, index) 
      model.setData(index, Qt::Variant.new(editor.isChecked))
    end

    def updateEditorGeometry(editor, item,  index)
      editor.setGeometry(item.rect)
    end

    def paint(painter, option, index)
      data = index.model.data(index)
      @opts ||= Qt::StyleOptionButton.new
      @opts.state = data.value == true ? Qt::Style::State_On : Qt::Style::State_Off
      @opts.rect = option.rect
  		Qt::Application.style.drawControl(Qt::Style::CE_CheckBox, @opts, painter)
    end  
  end
=end

  class ProgressBarD < Qt::ItemDelegate
    attr_accessor :filter_func, :controller
    
    def paint(painter, option, index)
      data = index.model.data_raw(index)
  		@opts ||= Qt::StyleOptionProgressBar.new
  		@opts.text = "Load"
      @opts.progress = if @filter_func 
                          @controller.send(@filter_func, data)
                        else
                          data
                        end
  		@opts.maximum = 100
  		@opts.minimum =   0
    	@opts.textVisible = true
  		@opts.textAlignment = Qt::AlignCenter
      @opts.rect = option.rect
  		Qt::Application.style.drawControl(Qt::Style::CE_ProgressBar, @opts, painter)
      super
    end  
  end


  class Table 
    include QtWidget

    def initialize(p)
      @widget = Qt::TableView.new
      #@widget.setMouseTracking(true)
      #@widget.connect(@widget, SIGNAL("entered(const QModelIndex &)"), @widget, SLOT("edit(const QModelIndex &)"))
      @widget.selectionBehavior=Qt::AbstractItemView::SelectRows
      @widget.selectionMode=Qt::AbstractItemView::MultiSelection
      p.add_element(self) 
      model = nil
    end
    def model=(model)
      @widget.model=model
    end
    def model
      @widget.model
    end
    def selection
      indices = @widget.selectionModel.selectedRows
      indices.collect{ |i| @widget.model.data_raw(i) }
    end
    
    def select_all
      topLeft = model.index(0, 0, @widget.parent)
      bottomRight = model.index(model.rowCount-1, model.columnCount-1)
      selection =  Qt::ItemSelection.new(topLeft, bottomRight)
      @widget.selectionModel.select(selection, Qt::ItemSelectionModel::Select)
    end

    def column(col, type, params={})
      case type
      when :Text
      return
      end
      @delegate = eval "#{type.to_s}D.new"
      @delegate.controller = @controller
      @delegate.filter_func = params[:filter]
      @widget.setItemDelegateForColumn(col, @delegate)
    end

  end

  class Label
    include QtWidget
    include ObserveAttr

    def initialize(p, *args)
      @widget = Qt::Label.new
      p.add_element(self)
      self.text=args[0]
    end
    def parse_params(params)
      @font = Qt::Font.new
      @font.PointSize =  params[:size] || 10 
      @widget.setFont(@font)
      super
    end

    def text=(value)
      @widget.setText(value.to_s)
    end
    def text
      @widget.text
    end


  end


  
  class Button 
    include QtWidget
    include ObserveAttr
    include EventHandleGenerator

    def text=(value) 
      @widget.setText(value)
    end

    def text
      @widget.text
    end

    def respond
      "<object type='application/x-qt-plugin' classid='#{self.object_id}'></object>"
    end    

    def initialize(p, *args)
      @widget = Qt::PushButton.new
      @widget.connect(SIGNAL(:clicked)) { emit(:click, self) }

      # CONTAINER layout
      @layout = Qt::HBoxLayout.new
      @layout.spacing = 0
      @layout.margin = 0
      @widget.setLayout(@layout)
      p.add_element(self)
      self.text=args[0]
    end


    def parse_params(params)
      method_click = params[:click]
      height = params[:height]
      @widget.setMinimumSize( Qt::Size.new(height, height) ) if height
      #@widget.setMaximumSize( Qt::Size.new(60,60) )
      click(method_click) if method_click
      super
    end

    def add_element(w)
      @widget.layout.addWidget(w.widget)
    end

  end

  class Text
    include QtWidget
    include ObserveAttr


    def initialize(p, *args)
      @widget = Qt::TextEdit.new(p.widget)
      p.add_element(self)

      self.text=args[0]
    end
    def parse_params(params)
      @widget.read_only = params[:value] || true
      super
    end
    def text=(value)
      @widget.append("#{value.to_s}") # text = @text.to_s
    end
  end


  class Field 
    include QtWidget
    include ObserveAttr
    observe_attr :text

    def initialize(p, *args)
      @widget = Qt::LineEdit.new
      @widget.connect(SIGNAL("textChanged(const QString &)")) {|m| emit("text_changed", m) }
      @widget.connect(SIGNAL(:returnPressed)) { emit(:enter, self) }

      p.add_element(self)
      self.text=args[0]
    end

    def completion=(value)
      @completer = Qt::Completer.new(value)
      @completer.case_sensitivity = Qt::CaseInsensitive
      @widget.setCompleter(@completer)
    end


    def text=(value)
      @widget.setText(value.to_s)
    end
    def text
      @widget.text
    end
  end

  class Svg
    include QtWidget
    include ObserveAttr

    def initialize(p)
      @widget = Qt::SvgWidget.new
      p.add_element(self) 
    end
    def parse_params(params)
      filename =  "resources/images/" + params[:file] || nil
      @widget.load(filename)
      super
    end
  end

  class Spin
    include QtWidget
    include ObserveAttr
    observe_attr :value

    def initialize(p, *args)
      @widget = Qt::SpinBox.new
      @widget.connect(SIGNAL("valueChanged(int)")) {|m| emit("value_changed", m) }
      p.add_element(self) 
    end
    def value=(value)
      @widget.value=value
    end
    def value
      @widget.value
    end

    def parse_params(params)
      @widget.maximum = params[:max] || 100
      @widget.minimum = params[:min] || 0
      @widget.value = params[:value] || 50
      super
    end
  end

  class Tabs
    include QtWidget 
    
    def initialize(p, *args)
      @widget = Qt::TabWidget.new
      p.add_element(self) 
    end
    def add(title, element)
      @widget.addTab(element.widget, title)
    end
    def add_element(w)
      @widget.addTab(w.widget, w.class.name || "")
    end
  end

  module Slider
    include QtWidget
    include ObserveAttr
    def parse_params(params)
      @widget.maximum = params[:max] || 100
      @widget.minimum = params[:min] || 0
      @widget.value = params[:value] || 50
      super
    end
    def value=(value)
      @widget.value=value
    end
    def value
      @widget.value
    end
  end

  class HSlider
    include Slider
    include ObserveAttr
    observe_attr :value

    def initialize(p)
      @widget = Qt::Slider.new(Qt::Horizontal)
      @widget.connect(SIGNAL("valueChanged(int)")) {|m| emit("value_changed", m) }
      p.add_element(self) 
    end
  end
  class VSlider
    include Slider
    include ObserveAttr
    observe_attr :value

    def initialize(p)
      @widget = Qt::Slider.new(Qt::Vertical)
      @widget.connect(SIGNAL("valueChanged(int)")) {|m| emit("value_changed", m) }
      p.add_element(self) 
    end
  end

  class Check
    include QtWidget

    def initialize(p, *args)
      @widget = Qt::CheckBox.new
      p.add_element(self)
      self.text=(args[0])
    end
    def parse_params(params)
      super
    end
    def text=(value) 
      @widget.setText(value)
    end
  end

  class Radio
    include QtWidget

    def initialize(p, *args)
      @widget = Qt::RadioButton.new(p.widget)
      p.add_element(self)
      self.text=(args[0])
    end
    def parse_params(params)
      super
    end
    def text=(value) 
      @widget.setText(value)
    end
  end

  class Group
    include QtWidget

    def initialize(p, *args)
      @widget = Qt::GroupBox.new(p.widget)
      @layout = Qt::HBoxLayout.new
      @widget.setLayout(@layout)
      p.add_element(self)
      self.text=(args[0])
    end
    def parse_params(params)
      @widget.checkable = params[:radio] || false
      super
    end
    def text=(value) 
      @widget.setTitle(value)
    end
    def add_element(w)
      @widget.layout.addWidget(w.widget)
    end
  end

  class Flow 
    include QtWidget
    
    def initialize(p)
      @widget = Qt::Widget.new(p.widget)
      @layout = Qt::HBoxLayout.new
      @widget.setLayout(@layout)
      p.add_element(self) 
    end
    

    def stretch
      @layout.addStretch(1)
    end
    def parse_params(params)
      @widget.layout.spacing = params[:spacing] || 1
      @widget.layout.margin = params[:margin] || 1
  #    filename =  "resources/images/" + (params[:file] || "")
  #    if filename @widget.load(filename)
      super
    end

    def spacing=(value)
      @layout.spacing=value
    end

    def margin=(value)
      @layout.margin=value
    end

    def add_element(w)
      @widget.layout.addWidget(w.widget)
    end
  end


  class Stack 
    include QtWidget
    
    def initialize(p)
      @widget = Qt::Widget.new(p.widget)
      @layout = Qt::VBoxLayout.new
      @widget.setLayout(@layout)
      p.add_element(self) 
    end

    def stretch
      @layout.addStretch(1)
    end
    def parse_params(params)
      @widget.layout.spacing = params[:spacing] || 1
      @widget.layout.margin = params[:margin] || 1
      super
    end

    def spacing=(value)
      @layout.spacing=value
    end

    def margin=(value)
      @layout.margin=value
    end

    def add_element(w)
      @widget.layout.addWidget(w.widget)
    end
  end
  
  class Action
    include QtWidget
    attr_accessor :qt_action
     
    def initialize(p, text, method, *args)
      @qt_action = Qt::Action.new(text, p.widget)
      @qt_action.connect(SIGNAL("triggered(bool)")) { emit(:click, self) }
      self.connect(:click, p.controller, method, *args)
      p.add_element(self) 
    end
    def parse_params(params)
    end
  end
  
  class Menu
    include QtWidget

    def initialize(p, *args)
      widget = @widget = Qt::Menu.new( args[0] || "menu", p.widget)
      
      case args[0].to_s
      when "context"
        p.widget.instance_eval %{
          @menu = widget
          def contextMenuEvent(event)
            @menu.popup(event.globalPos)
          end
        }
      end
      p.add_element(self) 
    end

    def separator
      @widget.addSeparator()
    end

 
    def add_element(w)
      case w.class.name
      when "Indigo::SomeGui::Qt4Backend::Menu"
        @widget.addMenu(w.widget)
      when "Indigo::SomeGui::Qt4Backend::Action"
        @widget.addAction(w.qt_action)  
      end
    end
  end

end
end
end