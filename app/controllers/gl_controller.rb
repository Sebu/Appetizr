

class AddController <  Indigo::Controller
  include Gl

  def show
    @add = Add.new  
    render
  end

  def gl_init
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glEnable(GL_DEPTH_TEST)
    glMatrixMode(GL_PROJECTION)
    glPushMatrix
  	glLoadIdentity
  	glOrtho(-10.0, 10.0, -10.0, 10.0, -10.0, 10.0)
    glMatrixMode(GL_MODELVIEW)
  end

  def gl_draw
    glPushMatrix
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
  	glLoadIdentity
    glRotatef(@add.rotation,0.0, 0.0, 1.0)
    glBegin(GL_QUADS)
      glVertex3f(-5,-5,0)
      glVertex3f(5,-5,0)
      glVertex3f(5,5,0)
      glVertex3f(-5,5,0)
    glEnd
    glPopMatrix
    glMatrixMode(GL_PROJECTION)
    glPopMatrix

  end


  def gl_resize(w,h)
    glViewport(0, 0, w, h)
  end

end

