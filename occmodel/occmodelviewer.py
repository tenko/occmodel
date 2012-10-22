# -*- coding: utf-8 -*-
import sys
import math
import array
import itertools

import geotools as geo
import gltools as gl
import occmodel as occ

COLORS = {
    'red'   :gl.ColorRGBA(255,0,0,255),
    'green' :gl.ColorRGBA(0,255,0,255),
    'blue'  :gl.ColorRGBA(0,0,255,255),
    'yellow':gl.ColorRGBA(255,255,0,255),
    'white' :gl.ColorRGBA(0,0,0,0),
    'grey' :gl.ColorRGBA(128,128,128,255),
    'black' :gl.ColorRGBA(255,255,255,255),
}

class PolylineObj(object):
    pass
    
class FaceObj(object):
    pass

class SolidObj(object):
    pass

class PolylineObj(object):
    pass
    
class FaceObj(object):
    pass

class SolidObj(object):
    pass
    
GLSL_VERTEX_PONG = \
"""
varying vec3 vN;
varying vec3 v;
void main(void)  
{     
   v = vec3(gl_ModelViewMatrix * gl_Vertex);       
   vN = normalize(gl_NormalMatrix * gl_Normal);
   gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;  
}
"""

GLSL_FRAG_PONG = \
"""
varying vec3 vN;
varying vec3 v; 

#define MAX_LIGHTS 3 
void main (void) 
{ 
   vec3 N = normalize(vN);
   vec4 finalColor = vec4(0.0, 0.0, 0.0, 0.0);
   
   for (int i=0;i<MAX_LIGHTS;i++)
   {
      vec3 L = normalize(gl_LightSource[i].position.xyz - v); 
      vec3 E = normalize(-v); // we are in Eye Coordinates, so EyePos is (0,0,0) 
      vec3 R = normalize(-reflect(L,N)); 
   
      //calculate Ambient Term: 
      vec4 Iamb = gl_FrontLightProduct[i].ambient; 
      //calculate Diffuse Term: 
      vec4 Idiff = gl_FrontLightProduct[i].diffuse * max(dot(N,L), 0.0);
      Idiff = clamp(Idiff, 0.0, 1.0); 
   
      // calculate Specular Term:
      vec4 Ispec = gl_FrontLightProduct[i].specular 
             * pow(max(dot(R,E),0.0),0.3*gl_FrontMaterial.shininess);
      Ispec = clamp(Ispec, 0.0, 1.0); 
   
      finalColor += Iamb + Idiff + Ispec;
   }
   
   // write Total Color: 
   gl_FragColor = gl_FrontLightModelProduct.sceneColor + finalColor; 
}
"""

GLSL_VERTEX_FLAT = \
"""
varying vec4 col;

void main(void)  
{     
   col = gl_Color;
   gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;  
}
"""

GLSL_FRAG_FLAT = \
"""
varying vec4 col;

void main (void) 
{ 
   gl_FragColor = col; 
}
"""
        
class Viewer(gl.Window):
    def __init__(self, width = -1, height = -1, title = None, fullscreen = False):
        self.initialized = False
        
        self.cam = geo.Camera()
        
        self.bbox = geo.AABBox()
        self.bbox.invalidate()
        
        self.lastPos = 0,0
        self.currentButton = -1
        self.showUI = True
        
        self.projectionMatrix = geo.Transform()
        self.modelviewMatrix = geo.Transform()
        
        self.clearColor = gl.ColorRGBA(90,90,90,255)
        self.objects = set()
        
        gl.Window.__init__(self, width, height, title, fullscreen)
    
    def addObject(self, obj, color = None):
        
        if color is None:
            color = COLORS['grey']
            
        elif isinstance(color, basestring):
            if color.lower() in COLORS:
                color = COLORS[color.lower()]
            else:
                raise GLError("Unknown color: '%s'" % color)
        
        if isinstance(obj, (occ.Edge, occ.Wire)):
            res = PolylineObj()
            res.color = color
            
            tess = obj.tesselate()
            
            # update bounding box
            bbox = obj.boundingBox()
            self.bbox.addPoint(bbox.min)
            self.bbox.addPoint(bbox.max)
            
            # create vertex buffer
            buffer = res.buffer = gl.ClientBuffer()
            
            vertSize = 3*tess.nvertices()
            vertItemSize = tess.verticesItemSize
            
            buffer.loadData(tess.vertices, vertSize*vertItemSize)
            buffer.setDataType(gl.VERTEX_ARRAY, gl.FLOAT, 3, 0, 0)
            
            # copy range object
            res.range = tuple(tess.ranges)
            res.rangeSize = tess.nranges()
            
            self.objects.add(res)
            
        elif isinstance(obj, occ.Face):
            res = FaceObj()
            
            mesh = obj.createMesh()
            
            # update bounding box
            bbox = obj.boundingBox()
            self.bbox.addPoint(bbox.min)
            self.bbox.addPoint(bbox.max)
            
            # create vertex & normal buffer
            buffer = res.buffer = gl.ClientBuffer()
            
            vertSize = 3*mesh.nvertices()
            vertItemSize = mesh.verticesItemSize

            normSize = 3*mesh.nnormals()
            normItemSize = mesh.normalsItemSize
            
            buffer.loadData(None, vertSize*vertItemSize + normSize*normItemSize)
            
            offset = 0
            size = vertSize*vertItemSize
            buffer.setDataType(gl.VERTEX_ARRAY, gl.FLOAT, 3, 0, 0)
            buffer.loadData(mesh.vertices, size, offset)
            offset += size
            
            size = normSize*normItemSize
            buffer.setDataType(gl.NORMAL_ARRAY, gl.FLOAT, 3, 0, offset)
            buffer.loadData(mesh.normals, size, offset)
            
            # create tri indices buffer
            tribuffer = res.triBuffer = gl.ClientBuffer(gl.ELEMENT_ARRAY_BUFFER)
            
            triSize = 3*mesh.ntriangles()
            triItemSize = mesh.trianglesItemSize
            
            tribuffer.loadData(mesh.triangles, triSize*triItemSize)
            res.triSize = triSize
            
            # add material
            res.frontMaterial = gl.Material(
                ambient = .3*color,
                diffuse = color,
                specular = gl.ColorRGBA(200,200,200,255),
                shininess = 128.,
            )
            
            res.backMaterial = gl.Material(
                ambient = .2*color,
                diffuse = .7*color,
                specular = gl.ColorRGBA(100,100,100,255),
                shininess = 128.,
            )
        
            self.objects.add(res)
        
        elif isinstance(obj, occ.Solid):
            res = SolidObj()
            
            mesh = obj.createMesh()
            
            # update bounding box
            bbox = obj.boundingBox()
            self.bbox.addPoint(bbox.min)
            self.bbox.addPoint(bbox.max)
            
            # create vertex & normal buffer
            buffer = res.buffer = gl.ClientBuffer()
            
            vertSize = 3*mesh.nvertices()
            vertItemSize = mesh.verticesItemSize

            normSize = 3*mesh.nnormals()
            normItemSize = mesh.normalsItemSize
            
            buffer.loadData(None, vertSize*vertItemSize + normSize*normItemSize)
            
            offset = 0
            size = vertSize*vertItemSize
            buffer.setDataType(gl.VERTEX_ARRAY, gl.FLOAT, 3, 0, 0)
            buffer.loadData(mesh.vertices, size, offset)
            offset += size
            
            size = normSize*normItemSize
            buffer.setDataType(gl.NORMAL_ARRAY, gl.FLOAT, 3, 0, offset)
            buffer.loadData(mesh.normals, size, offset)
            
            # create tri indices buffer
            tribuffer = res.triBuffer = gl.ClientBuffer(gl.ELEMENT_ARRAY_BUFFER)
            
            triSize = 3*mesh.ntriangles()
            triItemSize = mesh.trianglesItemSize
            
            tribuffer.loadData(mesh.triangles, triSize*triItemSize)
            res.triSize = triSize
            
            # add material
            res.material = gl.Material(
                ambient = .3*color,
                diffuse = color,
                specular = gl.ColorRGBA(200,200,200,255),
                shininess = 128.,
            )
        
            self.objects.add(res)
            
    def onSetup(self):
        self.ui = gl.UI()
        gl.ClearColor(self.clearColor)
        gl.ClearDepth(1.)
        
        gl.InitGLExt()
        
        # Lights
        lightMat = gl.Material(
            diffuse = gl.ColorRGBA(155,155,255,255),
            ambient = gl.ColorRGBA(55,55,25,255),
            specular = gl.ColorRGBA(255,255,255,255)
        )
        
        light0 = self.light0 = gl.Light(
            0,
            lightMat,
            geo.Point(0.,50.,100.),
        )
        
        light1 = self.light1 = gl.Light(
            1,
            lightMat,
            geo.Point(50.,0.,-100.),
        )
        
        light2 = self.light2 = gl.Light(
            2,
            lightMat,
            geo.Point(0.,-50.,0.),
        )
        
        # GLSL
        glsl = self.glslFlat = gl.ShaderProgram()
        glsl.build(GLSL_VERTEX_FLAT, GLSL_FRAG_FLAT)
        
        glsl = self.glslPong = gl.ShaderProgram()
        glsl.build(GLSL_VERTEX_PONG, GLSL_FRAG_PONG)
        
    def onSize(self, w, h):
        self.width, self.height = w - 1, h - 1
        
        if self.width > 1 and self.height > 1:
            # Adjust frustum to viewport aspect
            frustum_aspect = float(self.width) / self.height
            self.cam.setFrustumAspect(frustum_aspect)
            self.cam.setViewportSize(self.width, self.height)
            
            self.makeContextCurrent()
            gl.Viewport(0, 0, self.width, self.height)
            
        # initialize
        if not self.initialized:
            self.onSetup()
            self.cam.zoomExtents(self.bbox.min, self.bbox.max)
            self.initialized = True
        
    def onRefresh(self):
        if not self.running:
            return
        
        self.makeContextCurrent()
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
        
        gl.Enable(gl.DEPTH_TEST)
        gl.Enable(gl.MULTISAMPLE)
        gl.Enable(gl.DITHER)
        gl.Disable(gl.BLEND)
        gl.Disable(gl.CULL_FACE)
        gl.LightModeli(gl.LIGHT_MODEL_TWO_SIDE, gl.TRUE)
        
        gl.MatrixMode(gl.PROJECTION)
        self.projectionMatrix.cameraToClip(self.cam)
        gl.LoadMatrixd(self.projectionMatrix)
        
        gl.MatrixMode(gl.MODELVIEW)
        self.modelviewMatrix.worldToCamera(self.cam)
        gl.LoadMatrixd(self.modelviewMatrix)
        
        for obj in self.objects:
            if isinstance(obj, (SolidObj,FaceObj)):
                self.glslPong.begin()
                
                gl.Enable(gl.LIGHTING)
                self.light0.enable()
                self.light1.enable()
                self.light2.enable()
        
                gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
                
                obj.buffer.bind()
                obj.triBuffer.bind()
                
                if isinstance(obj, FaceObj):
                    obj.frontMaterial.enable()
                    obj.backMaterial.enable()
                else:
                    obj.material.enable()
                    
                gl.DrawElements(gl.TRIANGLES, obj.triSize, gl.UNSIGNED_INT, 0)
                obj.buffer.unBind()
                obj.triBuffer.unBind()
                
                self.glslPong.end()
            
            else:
                self.glslFlat.begin()
                
                gl.Disable(gl.LIGHTING)
                
                gl.Color(obj.color)
                gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
                gl.Enable(gl.LINE_SMOOTH)
                gl.LineWidth(1.2)
                
                obj.buffer.bind()
                
                i = 0
                while i < obj.rangeSize:
                    gl.DrawArrays(gl.LINE_STRIP, obj.range[i], obj.range[i + 1])
                    i += 2
                    
                obj.buffer.unBind()
                
                self.glslFlat.end()
        
        # draw user interface
        gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
        gl.Disable(gl.DEPTH_TEST)
        gl.Disable(gl.LIGHTING)
        gl.Disable(gl.DITHER)
        gl.Enable(gl.BLEND)
        gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
        
        gl.MatrixMode(gl.PROJECTION)
        gl.LoadIdentity()
        gl.Ortho(0,self.width,0,self.height,-1,1)
        gl.MatrixMode(gl.MODELVIEW)
        gl.LoadIdentity()
        
        update = self.onUI()
        
        self.swapBuffers()
        
        if update:
            self.onRefresh()
    
    def activeUI(self, x, y):
        w, h = self.width, self.height
        y = h - y
        
        if not self.showUI:
            return False
        
        if self.ui.anyActive():
            return True
            
        if x >= 10 and x <= 200:
            if y >= .4*h and y <= h - 10:
                return True
        
        return False
        
    def onUI(self):
        if not self.showUI:
            return False
        
        ui = self.ui
        update = False
        w, h = self.width, self.height
        x, y = self.lastPos
        
        ui.beginFrame(x,h - y,self.currentButton,0)
        ui.beginScrollArea("Menu", 10, .4*h, 200, .6*h - 10)
        
        ui.separatorLine()
        
        ui.label("View presets")
        ui.indent()
        if ui.item('Top', True):
            self.onTopView()
            update = True
        
        if ui.item('Bottom', True):
            self.onBottomView()
            update = True
        
        if ui.item('Front', True):
            self.onFrontView()
            update = True
        
        if ui.item('Back', True):
            self.onBackView()
            update = True
        
        if ui.item('Left', True):
            self.onLeftView()
            update = True
        
        if ui.item('Right', True):
            self.onRightView()
            update = True
        
        if ui.item('Iso', True):
            self.onIsoView()
            update = True
            
        ui.unindent()
        ui.separatorLine()
        
        ui.endScrollArea()
        ui.endFrame()
        ui.flush()
        
        return update
        
    def onCursorPos(self, x, y):
        width, height = self.width, self.height
        lastx,lasty = self.lastPos  
        cam = self.cam
        
        ui = self.activeUI(x, y)
        
        if not ui and self.currentButton == gl.MOUSE.LEFT:
            # rotate view
            dx = x - lastx
            dy = y - lasty
            
            if dx != 0:
                cam.rotateCamera(0.001*dx, geo.Vector(0.,0.,1.), cam.target)
            
            if dy != 0:
                cam.rotateCamera(0.001*dy, cam.X, cam.target)
        
        elif not ui and self.currentButton == gl.MOUSE.RIGHT:
            # pan view
            d = geo.dot(geo.Vector(cam.Loc - cam.target), cam.Z)
            dolly_vector = cam.getDollyCameraVector(lastx,lasty,x,y,d)
            cam.Loc += dolly_vector
            
        self.lastPos = x, y
        self.onRefresh()
        
    def onMouseButton(self, button, action):
        if action == gl.ACTION.PRESS:
            if button in {gl.MOUSE.LEFT, gl.MOUSE.RIGHT}:
                self.currentButton = button
        else:
            self.currentButton = -1
        
        self.onRefresh()
    
    def onKey(self, key, action):
        if key == gl.KEY.ESCAPE:
            self.running = False
    
    def onChar(self, ch):
        if ch == 'f':
            self.onZoomExtents()
            self.onRefresh()
            
        elif ch == 'm':
            self.showUI = not self.showUI
            self.onRefresh()
    
    def onScroll(self, scx, scy):
        x, y = self.lastPos
        
        if self.activeUI(x, y):
            return
        
        delta = 1e-4*scy
        dx = delta*self.width
        dy = delta*self.height
        
        self.cam.zoomFactor(1. + max(dx,dy), (x, y))
        self.onRefresh()
        
    def onClose(self):
        return True
        
    def onZoomExtents(self):
        self.cam.zoomExtents(self.bbox.min, self.bbox.max)
    
    def onTopView(self):
        cam = self.cam
        cam.Loc = geo.Point(0.,0.,100.)
        cam.Dir = geo.Vector(0., 0., -1.)
        cam.Up = geo.Vector(0., 1., 0.)
        cam.updateCameraFrame()
        self.onZoomExtents()
        
    def onBottomView(self):
        cam = self.cam
        cam.Loc = geo.Point(0.,0.,-100.)
        cam.Dir = geo.Vector(0., 0., 1.)
        cam.Up = geo.Vector(0., -1., 0.)
        cam.updateCameraFrame()
        self.onZoomExtents()
    
    def onLeftView(self):
        cam = self.cam
        cam.Loc = geo.Point(100.,0.,0.)
        cam.Dir = geo.Vector(-1., 0., 0.)
        cam.Up = geo.Vector(0., 0., -1.)
        cam.updateCameraFrame()
        self.onZoomExtents()
    
    def onRightView(self):
        cam = self.cam
        cam.Loc = geo.Point(-100.,0.,0.)
        cam.Dir = geo.Vector(1., 0., 0.)
        cam.Up = geo.Vector(0., 0., -1.)
        cam.updateCameraFrame()
        self.onZoomExtents()
    
    def onFrontView(self):
        cam = self.cam
        cam.Loc = geo.Point(0.,-100.,0.)
        cam.Dir = geo.Vector(0., 1., 0.)
        cam.Up = geo.Vector(0., 0., -1.)
        cam.updateCameraFrame()
        self.onZoomExtents()
    
    def onBackView(self):
        cam = self.cam
        cam.Loc = geo.Point(0.,100.,0.)
        cam.Dir = geo.Vector(0., -1., 0.)
        cam.Up = geo.Vector(0., 0., -1.)
        cam.updateCameraFrame()
        self.onZoomExtents()
    
    def onIsoView(self):
        cam = self.cam
        cam.Loc = geo.Point(-57.7,-57.7,57.7)
        cam.Dir = geo.Vector(.577,.577,-.577)
        cam.Up = geo.Vector(0., 0., -1.)
        cam.updateCameraFrame()
        self.onZoomExtents()
        

def viewer(objs, colors = None):
    if not isinstance(objs, (tuple,list)):
       objs = (objs,)
    
    if not colors is None:
        if not isinstance(colors, (tuple,list)):
            colors = (colors,)
    else:
        colors = COLORS
        
    mw = Viewer(
        title = "Viewer ('m' - toggle Menu | 'f' - zoomFit | ESC - Quit | LMB - rotate | RMB - pan | scroll - zoom)"
    )
    
    for obj, color in itertools.izip(objs, itertools.cycle(colors)):
        # skip Null objects.
        if obj.isNull():
            print("skipped object: '%s'" % str(obj))
            continue
        
        mw.addObject(obj, color)
    
    mw.onIsoView()
    mw.mainLoop()
    
if __name__ == '__main__':
    e1 = occ.Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,-1.),radius = .5)
    f1 = occ.Face().createConstrained(e1, ((0.,.0,-.5),))
    
    viewer((e1,f1))