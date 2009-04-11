


module Indigo
module SomeGui
module Qt4Backend

  module Widget
    include Create
    include Signaling
    include ObserveAttr

    attr_accessor :widget
    attr_accessor :controller

    def parse_block(&block)
      if block_given? 
        block.call @parent
      end
      show_all
    end

    def show_all
    end

    def parse_params(params)
      @widget.windowOpacity =  params[:opacity] || 1.0
    end

    def drop(method, *args)
      controller = @controller
      
      @widget.setAcceptDrops(true)
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
          @controller.send(@dnd_drop_method,*(@dnd_drop_args+[data]))
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
        @dnd_drag_args = args
        @dnd_drag_method = method
        @controller = controller

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
           data = @controller.send(@dnd_drag_method,*@dnd_drag_args)
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
    include Widget
    include ObserveAttr

    def initialize(p, name)
      @widget = Qt::MainWindow.new(p.widget)
      self.text=name
    end

    def parse_params(params)
      #puts "#{params[:text]}"
      posx = params[:posx] || 100 
      posy = params[:posy] || 100
      width = params[:width]
      height = params[:height] 
      @widget.setGeometry(posx, posy, width, height) if width and height
      super
    end

    def text=(value) 
      @widget.setWindowTitle(value)
    end
    def text
      @widget.windowTitle
    end

    obsattr :text

    def add_element(w)
      @widget.setCentralWidget(w.widget)
    end
    def show_all
      @widget.show
    end
    def hide
      @widget.hide
    end
  end

  class Dialog 
    include Widget
    include ObserveAttr

    def initialize(p, title)
      @widget = Qt::Dialog.new(p.widget, Qt::CustomizeWindowHint | Qt::WindowTitleHint)
      @layout = Qt::HBoxLayout.new
      @widget.setLayout(@layout)
      self.text=title
    end

    def parse_params(params)
      #puts "#{params[:text]}"
      posx = params[:posx] || 100 
      posy = params[:posy] || 100
      width = params[:width]
      height = params[:height] 
      @widget.setGeometry(posx, posy, width, height) if width and height
      super
    end

    def text=(value) 
      @widget.setWindowTitle(value)
    end
    def text
      @widget.windowTitle
    end
    obsattr :text


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
    include Widget
    include ObserveAttr

    obsattr_reader :update, :func => :gl_update

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

  class CheckBoxD < Qt::ItemDelegate
    attr_accessor :filter_func, :controller

    def paint(painter, option, index)
      data = index.model.data(index)
  		@opts ||= Qt::StyleOptionButton.new
      @opts.state = Qt::Style::State_On
      @opts.rect = option.rect
  		Qt::Application.style.drawControl(Qt::Style::CE_CheckBox, @opts, painter)
    end  
  end


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
    include Widget

    def initialize(p)
      @widget = Qt::TableView.new
      p.add_element(self) 
      model = nil
    end
    def model=(model)
      @widget.model=model
    end
    def model
      @widget.model
    end

    def column(col, type, params={})
      case type
        when :Text: return
      end
      delegate = eval "#{type.to_s}D.new"
      delegate.controller = @controller
      delegate.filter_func = params[:filter]
      @widget.setItemDelegateForColumn(col, delegate)
    end

  end

  class Label
    include Widget
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
      @widget.setText(value)
    end
    def text
      @widget.text
    end
    obsattr :text

  end

  class Button 
    include Widget
    include ObserveAttr
    include EventHandleGenerator

    obsattr :background, :func=>"background", :override => true

    def text=(value) 
      @widget.setText(value)
    end
    def text
      @widget.text
    end
    obsattr :text

    
    def initialize(p, *args)
      @widget = Qt::PushButton.new
      @widget.connect(SIGNAL(:clicked)) { emit(:click, self) }
      @widget.setMinimumSize( Qt::Size.new(60,60) )
      @widget.setMaximumSize( Qt::Size.new(60,60) )
      # CONTAINER layout
      @layout = Qt::HBoxLayout.new
      @layout.spacing = 0
      @layout.margin = 0
      @widget.setLayout(@layout)
      p.add_element(self)
      self.text=args[0]
    end

    def background(value)
      @widget.setStyleSheet("background: '#{value}'")
    end

    def parse_params(params)
      method_click = params[:click]
      click(method_click) if method_click
      super
    end

    def add_element(w)
      @widget.layout.addWidget(w.widget)
    end

  end

  class Text
    include Widget
    include ObserveAttr

    def initialize(p, *args)
      @widget = Qt::TextEdit.new
      p.add_element(self)
      self.text=args[0]
    end
    def parse_params(params)
      @widget.read_only = params[:value] || true
      super
    end
    def text=(value)
      @widget.setText(value.to_s)
    end
    def text
      @widget.text
    end
    obsattr :text
  end


  class Field 
    include Widget
    include ObserveAttr

    def initialize(p, *args)
      @widget = Qt::LineEdit.new
      @widget.connect(SIGNAL("textChanged(const QString &)")) {|m| emit("text_changed", m) }
      @widget.connect(SIGNAL(:returnPressed)) { emit(:enter, self) }
      p.add_element(self)
      self.text=args[0]
    end

    def text=(value)
      @widget.setText(value.to_s)
    end
    def text
      @widget.text
    end
    obsattr :text
  end

  class Svg
    include Widget
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
    include Widget
    include ObserveAttr
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
    obsattr :value

    def parse_params(params)
      @widget.maximum = params[:max] || 100
      @widget.minimum = params[:min] || 0
      @widget.value = params[:value] || 50
      super
    end
  end

  class Tabs
    include Widget 
    
    def initialize(p, *args)
      @widget = Qt::TabWidget.new
      p.add_element(self) 
    end
    def tab_title(title)
      @tab_title = title
    end
    def add_element(w)
      @widget.addTab(w.widget, @tab_title || "")
    end
  end

  module Slider
    include Widget
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
    obsattr :value

    def initialize(p)
      @widget = Qt::Slider.new(Qt::Horizontal)
      @widget.connect(SIGNAL("valueChanged(int)")) {|m| emit("value_changed", m) }
      p.add_element(self) 
    end
  end
  class VSlider
    include Slider
    include ObserveAttr
    obsattr :value

    def initialize(p)
      @widget = Qt::Slider.new(Qt::Vertical)
      @widget.connect(SIGNAL("valueChanged(int)")) {|m| emit("value_changed", m) }
      p.add_element(self) 
    end
  end

  class Check
    include Widget

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
    include Widget

    def initialize(p, *args)
      @widget = Qt::RadioButton.new
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
    include Widget

    def initialize(p, *args)
      @widget = Qt::GroupBox.new
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
    include Widget
    
    def initialize(p)
      @widget = Qt::Widget.new
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
    include Widget
    
    def initialize(p)
      @widget = Qt::Widget.new
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

end
end
end
