

require 'controller'
require 'add'
require 'gl'


class AddController  
  include Controller
  include Gl

  def show
    @model_name = :add
    @add = Add.one  
    render
  end

  #TODO: not optimal update should happen in some model STUFF
  def update(v)
    @glw.gl_update
    v
  end

  def click(w)
#    @part ||= part :main
#    @part.show_all
  end

  def gl_init
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glEnable(GL_DEPTH_TEST)
    glMatrixMode(GL_PROJECTION)
  	glLoadIdentity
  	glOrtho(-10.0, 10.0, -10.0, 10.0, -10.0, 10.0)
    glMatrixMode(GL_MODELVIEW)
  end

  def gl_draw
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
  	glLoadIdentity
    glRotatef(@add.rotation,0.0, 0.0, 1.0)
    glBegin(GL_QUADS)
      glVertex3f(-5,-5,0)
      glVertex3f(5,-5,0)
      glVertex3f(5,5,0)
      glVertex3f(-5,5,0)
    glEnd()
  end


  def gl_resize(w,h)
    glViewport(0, 0, w, h)
  end

end

