# -*- coding: utf-8 -*-
ESCAPE = 27
MIN_NEAR_DIST = 0.0001
MIN_NEAR_OVER_FAR = 0.0001
PARALLEL, PROJECTED = 1, 2
    
cdef class Viewport:
    cdef public int projection
    
    cdef readonly Point camLoc
    cdef readonly Vector camDir
    cdef readonly Vector camUp
    cdef readonly Vector camX
    cdef readonly Vector camY
    cdef readonly Vector camZ
    
    cdef readonly double fvLeft
    cdef readonly double fvRight
    cdef readonly double fvBottom
    cdef readonly double fvTop
    cdef readonly double fvNear
    cdef readonly double fvFar
    
    cdef readonly int scrLeft
    cdef readonly int scrRight
    cdef readonly int scrBottom
    cdef readonly int scrTop
    cdef readonly double scrNear
    cdef readonly double scrFar
    
    cdef public Box bbox
    cdef public Point target
        
    def __init__(self, projection = PARALLEL):
        self.projection = projection
        
        self.camLoc = Point(0.,0.,100.)
        self.camDir = Vector(0., 0., -1.)
        self.camUp = Vector(0., 1., 0.)
        self.camX = Vector(1., 0., 0.)
        self.camY = Vector(0., 1., 0.)
        self.camZ = Vector(0., 0., 1.)
        
        self.fvLeft = -20.
        self.fvRight = 20.
        self.fvBottom = -20.
        self.fvTop = 20.
        self.fvNear = MIN_NEAR_DIST
        self.fvFar = 100.
        
        self.scrLeft = 0
        self.scrRight = 1000
        self.scrBottom = 0
        self.scrTop = 1000
        self.scrNear = 0
        self.scrFar = 1
        
        self.bbox = Box()
        self.target = self.bbox.center
    
    def updateCameraFrame(self):
        # Calculate camera frame
        camZ = Vector(-self.camDir).unit()
        d = dot(self.camUp, camZ)
        camY = Vector(self.camUp - d * camZ).unit()
        camX = cross(camY, camZ)
        
        self.camX = camX
        self.camY = camY
        self.camZ = camZ
        
    def setCameraAngle(self, angle):
        right, left = self.fvRight, self.fvLeft
        top, bot = self.fvTop, self.fvBottom
        near, far = self.fvNear, self.fvFar
        
        if angle < 0. or angle > .5*M_PI*(1. - SQRT_EPSILON):
            return
        
        d = near*tan(angle)
        
        w = right - left
        h = top - bot
        aspect = float(w) / h
        
        if aspect >= 1.:
            # width >= height
            half_w = d*aspect
            half_h = d
        else:
            # height > width
            half_w = d
            half_h = d/aspect
        
        self.fvLeft, self.fvRight = -half_w, half_w
        self.fvBottom, self.fvTop  = -half_h, half_h
        
    def setFrustumNearFar(self, n, f):
        right, left = self.fvRight, self.fvLeft
        top, bot = self.fvTop, self.fvBottom
        near, far = self.fvNear, self.fvFar
        
        if self.projection == PROJECTED:
            d = n/float(near)
            left *= d
            right *= d
            bot *= d
            top *= d
        
            self.fvTop, self.fvBottom = top, bot
            self.fvRight, self.fvLeft = right, left
       
        self.fvNear, self.fvFar = n, f
            
        
    def setFrustumAspect(self, frustum_aspect):
        # maintains camera angle
        assert frustum_aspect > 0
        right, left = self.fvRight, self.fvLeft
        top, bot = self.fvTop, self.fvBottom
        
        w = right - left
        h = top - bot
        
        if abs(h) > abs(w):
            d = abs(w) if h > 0. else -abs(w)
            d *= .5
            h = .5*(top + bot)
            bot = h - d
            top = h + d
            h = top - bot
        else:
            d = abs(h) if w > 0. else -abs(h)
            d *= .5
            w = .5*(left + right);
            left  = w - d
            right = w + d
            w = right - left
        
        if frustum_aspect > 1.0:
            # increase width
            d = .5*w*frustum_aspect
            w = .5*(left + right)
            left = w - d
            right = w + d
            w = right - left
        elif frustum_aspect < 1.0:
            # increase height
            d = .5*h/frustum_aspect
            h = .5*(bot + top)
            bot = h - d
            top = h + d
            h = top - bot
        
        self.fvRight, self.fvLeft = right, left
        self.fvTop, self.fvBottom = top, bot
    
    def worldToCamera(self):
        tr = Transform()
        camX, camY, camZ = self.camX, self.camY, self.camZ
        camLoc = self.camLoc
        
        tr[0][0] = camX.x
        tr[0][1] = camX.y
        tr[0][2] = camX.z
        tr[0][3] = -(camX.x*camLoc.x + camX.y*camLoc.y + camX.z*camLoc.z)
        tr[1][0] = camY.x
        tr[1][1] = camY.y
        tr[1][2] = camY.z
        tr[1][3] = -(camY.x*camLoc.x + camY.y*camLoc.y + camY.z*camLoc.z)
        tr[2][0] = camZ.x
        tr[2][1] = camZ.y
        tr[2][2] = camZ.z
        tr[2][3] = -(camZ.x*camLoc.x + camZ.y*camLoc.y + camZ.z*camLoc.z)
        tr[3][0] = tr[3][1] = tr[3][2] = 0.
        tr[3][3] = 1.
        return tr
    
    def cameraToWorld(self):
        tr = Transform()
        camX, camY, camZ = self.camX, self.camY, self.camZ
        camLoc = self.camLoc
        
        tr[0][0] = camX.x
        tr[0][1] = camY.x
        tr[0][2] = camZ.x
        tr[0][3] = camLoc.x
        tr[1][0] = camX.y
        tr[1][1] = camY.y
        tr[1][2] = camZ.y
        tr[1][3] = camLoc.y
        tr[2][0] = camX.z
        tr[2][1] = camY.z
        tr[2][2] = camZ.z
        tr[2][3] = camLoc.z
        tr[3][0] = tr[3][1] = tr[3][2] = 0.
        tr[3][3] = 1.

        return tr
        
    def clipToCamera(self):
        tr = Transform()
        right, left = self.fvRight, self.fvLeft
        top, bottom = self.fvTop, self.fvBottom
        far_dist, near_dist = self.fvFar, self.fvNear
        
        if self.projection != PROJECTED:
            # parallel projection
            tr[0][0] = .5*(right - left)
            tr[0][3] = .5*(right + left)
            tr[0][1] = tr[0][2] = 0.
            tr[1][1] = .5*(top - bottom)
            tr[1][3] = .5*(top + bottom)
            tr[1][0] = tr[1][2] = 0.
            tr[2][2] = .5*(far_dist - near_dist)
            tr[2][3] = -.5*(far_dist + near_dist)
            tr[2][0] = tr[2][1] = 0.
            tr[3][0] = tr[3][1] = tr[3][2] = 0.
            tr[3][3] = 1.
        else:
            d = .5/near_dist
            tr[0][0] = d*(right - left)
            tr[0][3] = d*(right + left)
            tr[0][1] = tr[0][2] = 0.

            tr[1][1] = d*(top - bottom)
            tr[1][3] = d*(top + bottom)
            tr[1][0] = tr[1][2] = 0.

            tr[2][0] = tr[2][1] = tr[2][2] = 0.
            tr[2][3] = -1.

            d /= far_dist
            tr[3][2] = d*(far_dist - near_dist)
            tr[3][3] = d*(far_dist + near_dist)
            tr[3][0] = tr[3][1] = 0.
        
        return tr
        
    def cameraToClip(self):
        tr = Transform()
        right, left = self.fvRight, self.fvLeft
        top, bottom = self.fvTop, self.fvBottom
        far_dist, near_dist = self.fvFar, self.fvNear
        
        if self.projection != PROJECTED:
            # parallel projection
            d = 1./(left - right)
            tr[0][0] = -2.*d
            tr[0][3] = (left + right)*d
            tr[0][1] = tr[0][2] = 0.
            d = 1./(bottom - top)
            tr[1][1] = -2.*d
            tr[1][3] = (bottom + top)*d
            tr[1][0] = tr[1][2] = 0.
            d = 1./(far_dist - near_dist)
            tr[2][2] = 2.*d
            tr[2][3] = (far_dist + near_dist)*d
            tr[2][0] = tr[2][1] = 0.
            
            tr[3][0] = tr[3][1] = tr[3][2] = 0.0
            tr[3][3] = 1.0
        
        else:
            # perspective projection
            d = 1./(right - left)
            tr[0][0] = 2.*near_dist*d
            tr[0][2] = (right + left)*d
            tr[0][1] = tr[0][3] = 0.
            
            d = 1./(top - bottom)
            tr[1][1] = 2.*near_dist*d
            tr[1][2] = (top + bottom)*d
            tr[1][0] = tr[1][3] = 0.
            
            d = 1./(far_dist - near_dist)
            tr[2][2] = (far_dist + near_dist)*d
            tr[2][3] = 2.0*near_dist*far_dist*d
            tr[2][0] = tr[2][1] = 0.
            
            tr[3][0] = tr[3][1] = tr[3][3] = 0.
            tr[3][2] = -1.
        
        return tr
    
    def loadProjectionMatrix(self):
        projectionMatrix = self.cameraToClip()
        projectionMatrix.transpose()
        glMatrixMode(GL_PROJECTION)
        mat = []
        for row in range(4):
            for col in range(4):
                mat.append(projectionMatrix[row][col])
        glLoadMatrixd(mat)
    
    def loadModelViewMatrix(self):
        modelviewMatrix = self.worldToCamera()
        modelviewMatrix.transpose()
        glMatrixMode(GL_MODELVIEW)
        mat = []
        for row in range(4):
            for col in range(4):
                mat.append(modelviewMatrix[row][col])
        glLoadMatrixd(mat)
        
    def setViewportSize(self, width, height):
        self.scrLeft = 0
        self.scrRight = width
        self.scrBottom = height
        self.scrTop = 0
        self.scrNear = 0
        self.scrFar =0xff
        glViewport(0, 0, width, height)
    
    def getDollyCameraVector(self, x0, y0, x1, y1, distance_to_camera):
        scrLeft, scrRight = self.scrLeft, self.scrRight
        scrBottom, scrTop = self.scrBottom, self.scrTop
        far_dist, near_dist = self.fvFar, self.fvNear
        
        tr = self.cameraToWorld() * self.clipToCamera()
        
        dx = .5*(scrRight - scrLeft)
        dy = .5*(scrTop - scrBottom)
        dz = .5*(far_dist - near_dist)
        
        z = (distance_to_camera - near_dist)/dz - 1.
        c0 = Point((x0 - scrLeft)/dx - 1., (y0 - scrBottom)/dy - 1., z)
        c1 = Point((x1 - scrLeft)/dx - 1., (y1 - scrBottom)/dy - 1., z)
        w0 = Vector(*tr.map(c0))
        w1 = Vector(*tr.map(c1))
        
        return w0 - w1
    
    
    def rotateCamera(self, angle, axis, center):
        rot = Transform()
        rot.rotateAxisCenter(angle, axis, center)
        
        self.camLoc = Point(*rot.map(self.camLoc))
        self.camDir = Vector(*rot.map(-self.camZ))
        self.camUp   = Vector(*rot.map(self.camY))
        self.updateCameraFrame()
    
    def zoomFactor(self, magnification_factor, fixed_screen_point = None):
        scrLeft, scrRight = self.scrLeft, self.scrRight
        scrBottom, scrTop = self.scrBottom, self.scrTop
        
        frus_right, frus_left = self.fvRight, self.fvLeft
        frus_top, frus_bottom = self.fvTop, self.fvBottom
        frus_far, frus_near = self.fvFar, self.fvNear
        
        camX, camY, camZ = self.camX, self.camY, self.camZ
        camLoc = self.camLoc
        target = self.target
            
        scr_width  = scrRight - scrLeft
        scr_height = scrBottom - scrTop
        
        if magnification_factor <= 0. or scr_width == 0 or scr_height == 0:
            return
        
        if fixed_screen_point:
            pnt = fixed_screen_point
            if pnt[0] <= 0 or pnt[0] >= scr_width -1:
                fixed_screen_point = None
            
            if pnt[1] <= 0 or pnt[1] >= scr_height -1:
                fixed_screen_point = None
        
        w0 = frus_right - frus_left
        h0 = frus_top - frus_bottom
        d = 0.
        
        if self.projection == PROJECTED:
            min_target_distance = 1.0e-6
            
            # dolly camera towards target point
            # 11 Sep 2002 - switch to V2 target based "zoom"
            target_distance = dot((camLoc - target), camZ)
            if target_distance >= 0.:
                delta = (1. - 1./magnification_factor)*target_distance
                if target_distance-delta > min_target_distance:
                    self.camLoc = camLoc - Point(delta*camZ)
                    if not fixed_screen_point is None:
                        d = target_distance/frus_near;
                        w0 *= d;
                        h0 *= d;
                        d = (target_distance - delta)/target_distance
        
        else:
            # parallel proj or "true" zoom
            # apply magnification to frustum
            d = 1./magnification_factor
            frus_left   *= d
            frus_right  *= d
            frus_bottom *= d
            frus_top    *= d
            
            self.fvRight, self.fvLeft = frus_right, frus_left
            self.fvTop, self.fvBottom = frus_top, frus_bottom
        
        if not fixed_screen_point is None and d != 0.: 
            # lateral dolly to keep fixed_screen_point 
            # in same location on screen
            fx = fixed_screen_point[0]/float(scr_width)
            fy = fixed_screen_point[1]/float(scr_height)
            dx = (.5 - fx)*(1. - d)*w0
            dy = (fy - .5)*(1. - d)*h0
            
            dolly_vector = dx*camX + dy*camY
            target -= Point(*dolly_vector)
            camLoc -= Point(*dolly_vector)
            
            self.target = target
            self.camLoc = camLoc
            
    
    def extents(self, angle):
        camX, camY, camZ = self.camX, self.camY, self.camZ
        bbox = self.bbox
        near, far = bbox.near, bbox.far
        center = bbox.center
        
        box_corner = bbox.near
        xmin = ymin = sys.maxint
        xmax = ymax = -sys.maxint
        
        pnts = (near.x,far.x), (near.y,far.y), (near.z,far.z)
        for value in itertools.product(*pnts):
            box_corner = Vector(*value)
            x = dot(camX, box_corner)
            y = dot(camY, box_corner)
            xmin = min(xmin, x)
            ymin = min(ymin, y)
            xmax = max(xmax, x)
            ymax = max(ymax, y)
        
        radius = xmax - xmin
        if ymax - ymin > radius:
            radius = ymax - ymin
        
        radius *= .5
        if radius <= SQRT_EPSILON:
            radius = 1.
        
        target_dist = radius/sin(angle)
        if self.projection != PROJECTED:
            target_dist += 1.0625*radius
        
        near_dist = target_dist - 1.0625*radius
        if near_dist < 0.0625*radius:
            near_dist = 0.0625*radius
            
        if near_dist < MIN_NEAR_DIST:
            near_dist = MIN_NEAR_DIST
            
        far_dist = target_dist + 1.0625*radius
        self.camLoc = center + target_dist*camZ
        self.setFrustumNearFar(near_dist, far_dist)
        self.setCameraAngle(angle)
        
        # FIXME! - Use calculated distances!
        self.fvNear, self.fvFar = 0.01, 10000.
        
        
    def zoomToFit(self):
        half_angle = 15.*M_PI/180.
        self.extents(half_angle)
        
    def resizeGL(self, width, height):
        if width > 1 and height > 1:
            # Adjust frustum to viewport aspect
            frustum_aspect = float(width - 1.) / (height - 1.)
            self.setFrustumAspect(frustum_aspect)
            self.setViewportSize(width - 1, height - 1)
            self.loadProjectionMatrix()
            self.loadModelViewMatrix()

COLORS = {
    'red'   :(1.,0.,0.,1.),
    'green' :(0.,1.,0.,1.),
    'blue'  :(0.,0.,1.,1.),
    'yellow':(1.,1.,0.,1.),
    'white' :(0.,0.,0.,0.),
    'black' :(1.,1.,1.,1.),
    'grey'  :(.5,.5,.5,1.),
}

cdef class Viewer(Viewport):
    '''
    General viewer class
    '''
    cdef bint first
    cdef readonly set objects
    cdef readonly object dls
        
    def __init__(self):
        Viewport.__init__(self)
        self.Clear()
        
    def Clear(self):
        self.first = True
        self.objects = set()
        self.dls = None
    
    def addObject(self, obj, bbox, color = 'grey'):
        self.objects.add((obj, color))
        
        # set bounding box
        if self.first:
            self.bbox = bbox
            self.first = False
        else:
            self.bbox.addPoint(bbox.near)
            self.bbox.addPoint(bbox.far)
    
    def OnSetup(self):
        cdef float material[4]
        glClearColor(0.15, 0.15, 0.40, 1.0)
        
        glDepthRange(0., 1.)
        glClearDepth(1.)
        glDepthFunc(GL_LEQUAL)
        glEnable(GL_DEPTH_TEST)
        glDepthMask(GL_TRUE)
        glEnable(GL_DEPTH_TEST)
        
        glEnable(GL_LIGHTING)
        glEnable(GL_LIGHT0)
        
        material[:] = [1.0, 1.0, 1.0,1.0]
        glLightfv(GL_LIGHT0, GL_SPECULAR, material)
        material[:] = [0.0, 0.0, 0.0,1.0]
        glLightfv(GL_LIGHT0, GL_AMBIENT, material)
        material[:] = [1.0, 1.0, 1.0,1.0]
        glLightfv(GL_LIGHT0, GL_DIFFUSE, material)
    
    def OnDraw(self):
        cdef float material[4]
        
        DEFCOL = COLORS['grey']
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        glPushAttrib(GL_ALL_ATTRIB_BITS)
        
        glEnable(GL_MULTISAMPLE)
        glEnable(GL_DITHER)
        material[:] = [0.,0.,0.,0.]
        glLightModelfv(GL_LIGHT_MODEL_AMBIENT, material)

        glFrontFace(GL_CCW)
        glDisable(GL_CULL_FACE)
        
        if self.dls is None:
            dls = self.dls = set()
            for obj,color in self.objects:
                dl = DisplayList()
                dl.start()
                
                if isinstance(obj, Mesh):
                    glEnable(GL_LIGHTING)
                    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
                    glShadeModel(GL_SMOOTH)
                    
                    material[:] = [1.,1.,1.,1.]
                    glMaterialfv(GL_FRONT, GL_SPECULAR, material)
                    material[:] = [100.,100.,100.,100.]
                    glMaterialfv(GL_FRONT, GL_SHININESS, material)
                    
                    color = COLORS.get(color, DEFCOL)
                    for i in range(4):
                        material[i] = color[i]
                    
                    glMaterialfv(GL_FRONT, GL_DIFFUSE, material)
                    
                    glBegin(GL_TRIANGLES)
                    obj.GLTriangles()
                    glEnd()
                else:
                    glDisable(GL_LIGHTING)
                    glShadeModel(GL_FLAT)
                    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
                    glLineWidth(2)
                    
                    objcolor = COLORS.get(color, DEFCOL)
                    glColor4d(objcolor[0], objcolor[1], objcolor[2], objcolor[3])
                    
                    glBegin(GL_LINE_STRIP)
                    for vertex in obj:
                        glVertex3d(vertex[0], vertex[1], vertex[2])
                    glEnd()
                    
                dl.end()
                dls.add(dl)
        
        for dl in self.dls:
            dl()
        
        
        glPopMatrix()
        glMatrixMode(GL_PROJECTION);
        glPopMatrix()
        glPopAttrib()
        glFlush()
        
GLUT_ESCAPE = 27

cdef class GLUTViewer(Viewer):
    cdef tuple lastPos
    cdef int width, height
    cdef object currentButton
    cdef object currentState
    
    def __init__(self, width, height, title = "Viewer (f - zoomFit | esc - Quit)"):
        Viewer.__init__(self)
        
        glutInit(sys.argv)
        glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH)
        glutInitWindowSize(width, height)
        glutCreateWindow(title)
        glutDisplayFunc(self.OnDisplay)
        glutKeyboardFunc(self.OnKeyboard)
        glutMouseFunc(self.OnMouse)
        glutMotionFunc(self.OnMotion)
        glutReshapeFunc(self.OnReshape)
        
        self.lastPos = 0,0
        self.width, self.height = width, height
        self.currentButton = None
        self.currentState = None
    
    def Show(self):
        glutMainLoop()
        
    def OnFit(self):
        self.zoomToFit()
        self.loadProjectionMatrix()
        self.loadModelViewMatrix()
        glutPostRedisplay()
            
    def OnKeyboard(self, key, x, y):
        if key == GLUT_ESCAPE:
            # press escape for exit
            glutDestroyWindow(glutGetWindow())
        
        elif key == ord('f'):
            self.OnFit()
            
    def OnMouse(self, button, state, x, y):
        self.currentButton = None
        
        if button in {GLUT_LEFT_BUTTON, GLUT_RIGHT_BUTTON}:
            if state == GLUT_DOWN:
                self.currentButton = button
                self.currentState = state
                self.lastPos = x, y
                return
        
        elif button in {GLUT_WHEEL_UP, GLUT_WHEEL_DOWN}:
            if state == GLUT_DOWN:
                # zoom
                if button == GLUT_WHEEL_UP:
                    delta = 1e-5
                else:
                    delta = -1e-5
                dx = delta*self.width
                dy = delta*self.height
                
                self.zoomFactor(1 + max(dx,dy), (x, y))
                self.loadProjectionMatrix()
                self.loadModelViewMatrix()
                glutPostRedisplay()
    
    def OnMotion(self, x, y):
        width, height = self.width, self.height
        lastx,lasty = self.lastPos  
        
        if self.currentButton == GLUT_LEFT_BUTTON:
            # rotate view
            dx = x - lastx
            dy = y - lasty
            
            if dx != 0:
                self.rotateCamera(0.01*dx, Vector(0.,0.,1.), self.target)
            
            if dy != 0:
                self.rotateCamera(0.01*dy, self.camX, self.target)
                
        elif self.currentButton == GLUT_RIGHT_BUTTON:
            # pan view
            camZ = self.camZ
            camLoc = self.camLoc
            
            d = dot(Vector(camLoc - self.target), camZ)
            dolly_vector = self.getDollyCameraVector(lastx,lasty,x,y,d)
            self.camLoc += dolly_vector
                
        else:
            return
            
        self.lastPos = x, y
        self.loadProjectionMatrix()
        self.loadModelViewMatrix()
        glutPostRedisplay()
            
    def OnReshape(self, width, height):
        self.width, self.height = width, height
        self.resizeGL(width - 1, height - 1)
        self.OnSetup()
        glutPostRedisplay()
    
    def OnDisplay(self):
        self.OnDraw()
        glutSwapBuffers()

ARC, FACE, BOX, PIPE = 1, 2, 3, 4
LOFT, UNION, DIFF, INT = 5, 6, 7, 8

class DemoViewer(GLUTViewer):
    def __init__(self, width, height):
        title = "Viewer (f - zoomFit | esc - Quit | Right mouse - menu)"
        GLUTViewer.__init__(self, width, height, title)
        
        self.menu = glutCreateMenu(self.OnMenu)
        glutSetMenu(self.menu)
        glutAddMenuEntry("Arc example", ARC)
        glutAddMenuEntry("Face example", FACE)
        glutAddMenuEntry("Box example", BOX)
        glutAddMenuEntry("Pipe example", PIPE)
        glutAddMenuEntry("Loft example", LOFT)
        glutAddMenuEntry("Union example", UNION)
        glutAddMenuEntry("Diff example", DIFF)
        glutAddMenuEntry("Int example", INT)
        glutAttachMenu(GLUT_RIGHT_BUTTON)
        
    def OnMenu(self, value):
        self.Clear()
        solid, edge, face = None, None, None
        
        if value == ARC:
            SRC = \
"""
start = Vertex(1.,0.,0.)
end = Vertex(-1.,0.,0.)
pnt = (0.,1.,0.)
edge = Edge().createArc3P(start,end,pnt)
"""
            start = Vertex(1.,0.,0.)
            end = Vertex(-1.,0.,0.)
            pnt = (0.,1.,0.)
            edge = Edge().createArc3P(start,end,pnt)
        
        elif value == FACE:
            SRC = \
"""
e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
face = Face().createFace(e1, ((0.,.5,.25),))
"""
            print >>sys.stdout, SRC
            
            e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
            face = Face().createFace(e1, ((0.,.5,.25),))
        
        elif value == BOX:
            SRC = \
"""
solid = Solid().createBox((0.,0.,0.),(100.,100.,100.))
solid.shell(-5, lambda near,far: near[2] > 50 and far[2] > 50)
solid.fillet(2., lambda near,far: True)
"""
            print >>sys.stdout, SRC
            
            solid = Solid().createBox((0.,0.,0.),(100.,100.,100.))
            solid.shell(-5, lambda near,far: near[2] > 50 and far[2] > 50)
            solid.fillet(2., lambda near,far: True)
            
        elif value == PIPE:
            SRC = \
"""
start = Vertex(0.,0.,0.)
end = Vertex(2.,0.,2.)
cen = (2.,0.,0.)
e1 = Edge().createArc(start,end,cen)

e2 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
f1 = Face().createFace(e2)

solid = Solid().pipe(f1, (e1,))
"""
            print >>sys.stdout, SRC
            
            start = Vertex(0.,0.,0.)
            end = Vertex(2.,0.,2.)
            cen = (2.,0.,0.)
            e1 = Edge().createArc(start,end,cen)

            e2 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
            f1 = Face().createFace(e2)
            
            solid = Solid().pipe(f1, (e1,))
        
        elif value == LOFT:
            SRC = \
"""
e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
e2 = Edge().createEllipse(center=(0.,0.,5.),normal=(0.,0.,1.), rMajor = 2.0, rMinor=1.0)
e3 = Edge().createCircle(center=(0.,0.,10.),normal=(0.,0.,1.),radius = 1.0)
solid = Solid().loft(((e1,),(e2,),(e3,)))
"""
            print >>sys.stdout, SRC
            
            e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
            e2 = Edge().createEllipse(center=(0.,0.,5.),normal=(0.,0.,1.), rMajor = 2.0, rMinor=1.0)
            e3 = Edge().createCircle(center=(0.,0.,10.),normal=(0.,0.,1.),radius = 1.0)
            solid = Solid().loft(((e1,),(e2,),(e3,)))
        
        elif value == UNION:
            SRC = \
"""
s1 = Solid().createSphere((0.,0.,0.),.5)
s2 = Solid().createSphere((.25,0.,0.),.5)
solid = s1.booleanUnion(s2)
"""
            print >>sys.stdout, SRC
            
            s1 = Solid().createSphere((0.,0.,0.),.5)
            s2 = Solid().createSphere((.25,0.,0.),.5)
            solid = s1.booleanUnion(s2)
        
        elif value == DIFF:
            SRC = \
"""
s1 = Solid().createSphere((0.,0.,0.),.5)
s2 = Solid().createSphere((.25,0.,0.),.5)
solid = s1.booleanDifference(s2)
"""
            print >>sys.stdout, SRC
            
            s1 = Solid().createSphere((0.,0.,0.),.5)
            s2 = Solid().createSphere((.25,0.,0.),.5)
            solid = s1.booleanDifference(s2)
        
        elif value == INT:
            SRC = \
"""
s1 = Solid().createSphere((0.,0.,0.),.5)
s2 = Solid().createSphere((.25,0.,0.),.5)
solid = s1.booleanIntersection(s2)
"""
            print >>sys.stdout, SRC
            
            s1 = Solid().createSphere((0.,0.,0.),.5)
            s2 = Solid().createSphere((.25,0.,0.),.5)
            solid = s1.booleanIntersection(s2)
            
        if not solid is None:
            bbox = solid.boundingBox()
            obj = solid.createMesh()
            
        elif not face is None:
            bbox = face.boundingBox()
            obj = face.createMesh()
            
        elif not edge is None:
            bbox = edge.boundingBox()
            obj = edge.tesselate()
            
        self.addObject(obj, bbox, 'blue')
        self.OnFit()
        glutPostRedisplay()
        
def demo():
    '''
    Simple demos
    '''
    viewer = DemoViewer(800,800)
    viewer.Show()
    
def viewer(objs, colors = None):
    '''
    View object or sequence of objects.
    Edges, faces and solids are supported
    '''
    viewer = GLUTViewer(800,800)
    
    if not isinstance(objs, (tuple,list)):
       objs = (objs,)
    
    if not colors is None:
        if not isinstance(colors, (tuple,list)):
            colors = (colors,)
    else:
        colors = COLORS
        
    for obj, color in itertools.izip(objs, itertools.cycle(colors)):
        if isinstance(obj, Edge):
            data = obj.tesselate()
        else:
            data = obj.createMesh()
        
        viewer.addObject(data, obj.boundingBox(), color)
    
    viewer.OnFit()
    viewer.Show()