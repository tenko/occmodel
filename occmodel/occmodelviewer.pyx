# -*- coding: utf-8 -*-
from __future__ import print_function
import sys
import math
import array
import itertools
import ctypes
import atexit

cimport geotools as geo
import geotools as geo

cimport gltools as gl
import gltools as gl

import occmodel as occ
from occmodel import OCCError

if sys.hexversion > 0x03000000:
    basestring = str

class InputHookManager(object):
    """
    Manage PyOS_InputHook.
    
    Code from IPython : BSD License
    """
    
    def __init__(self):
        self.PYFUNC = ctypes.PYFUNCTYPE(ctypes.c_int)
        self._reset()

    def _reset(self):
        self._callback_pyfunctype = None
        self._callback = None
        self._installed = False
        self._windows = set()
    
    def _get_pyos_inputhook(self):
        """Return the current PyOS_InputHook as a ctypes.c_void_p."""
        return ctypes.c_void_p.in_dll(ctypes.pythonapi,"PyOS_InputHook")

    def _get_pyos_inputhook_as_func(self):
        """Return the current PyOS_InputHook as a ctypes.PYFUNCYPE."""
        return self.PYFUNC.in_dll(ctypes.pythonapi,"PyOS_InputHook")

    def setInputHook(self, callback):
        """
        Set PyOS_InputHook to callback and return the previous one.
        """
        self._callback = callback
        self._callback_pyfunctype = self.PYFUNC(callback)
        pyos_inputhook_ptr = self._get_pyos_inputhook()
        original = self._get_pyos_inputhook_as_func()
        pyos_inputhook_ptr.value = \
            ctypes.cast(self._callback_pyfunctype, ctypes.c_void_p).value
        self._installed = True
        return original

    def clearInputHook(self):
        """
        Set PyOS_InputHook to NULL and return the previous one.
        """
        pyos_inputhook_ptr = self._get_pyos_inputhook()
        original = self._get_pyos_inputhook_as_func()
        pyos_inputhook_ptr.value = ctypes.c_void_p(None).value
        self._reset()
        return original
    
    def enable(self, win):
        self._windows.add(win)
        
        # input hook
        def InputHook(windows = self._windows):
            gl.PollEvents()
            # check for exceptions
            for win in windows:
                if not win.error is None:
                    error = win.error
                    win.error = None
                    raise error
            return 0
    
        self.setInputHook(InputHook)
        
        def removeInputHook(self):
            gl.Terminate()
            self.clearInputHook()
            
        atexit.register(removeInputHook, self)

inputHookManager = InputHookManager()

COLORS = {
    'red'   :gl.ColorRGBA(255,0,0,255),
    'green' :gl.ColorRGBA(0,255,0,255),
    'blue'  :gl.ColorRGBA(0,0,255,255),
    'yellow':gl.ColorRGBA(255,255,0,255),
    'white' :gl.ColorRGBA(0,0,0,0),
    'grey'  :gl.ColorRGBA(128,128,128,255),
    'black' :gl.ColorRGBA(255,255,255,255),
}

class BaseObj(object):
    def __init__(self, hashValue):
        self.__hash = hashValue
    
    def hashCode(self):
        return self.__hash
        
class PolylineObj(BaseObj):
    pass
    
class FaceObj(BaseObj):
    pass

class SolidObj(BaseObj):
    pass

LSHIFT, LCTRL = 1, 2

class Viewer(gl.Window):
    def __init__(self, width = -1, height = -1, title = None, fullscreen = False):
        self.initialized = False
        
        self.cam = geo.Camera()
        
        self.bbox = geo.AABBox()
        self.bbox.invalidate()
        
        self.lastPos = 0,0
        self.mouseStart = 0,0
        self.mouseCenter = geo.Point()
        self.currentButton = -1
        self.keyMod = 0
        
        self.uiBuffer = None
        self.uiActive = False
        self.uiRefresh = True
        self.uiScroll = 0
        self.uiGradient = True
        self.uiSpecular = False
        self.uiEdges = True
        self.uiHelp = False
        self.uiQuit = False
        self.screenShotCnt = 1
        
        self.projectionMatrix = geo.Transform()
        self.modelviewMatrix = geo.Transform()
        
        self.clearColor = gl.ColorRGBA(70,70,255,255)
        self.defaultColor = gl.ColorRGBA(10,10,255,255)
        self.pickColor = gl.ColorRGBA(255,255,55,255)
        self.edgeColor = gl.ColorRGBA(100,100,155,255)
        
        self.objects = set()
        self.drawables = set()
        self.hidden = set()
        self.picked = set()
        
        gl.Window.__init__(self, width, height, title, fullscreen)
    
    def redraw(self):
        '''
        Redraw view
        '''
        self.onRefresh()
        
    def clear(self):
        '''
        Remove all objects
        '''
        self.bbox.invalidate()
        self.objects.clear()
        self.drawables.clear()
        self.hidden.clear()
        self.picked.clear()
    
    def remove(self, obj):
        '''
        Remove object
        '''
        self.objects.discard(obj)
        hid = obj.hashCode()
        self.drawables.discard(hid)
        self.hidden.discard(hid)
        self.picked.discard(hid)
    
    def hide(self, obj):
        '''
        Hide object
        '''
        self.hidden.add(obj.hashCode())
    
    def unHide(self, obj = None):
        '''
        Unhide object
        '''
        if obj is None:
            self.hidden.clear()
        else:
            self.hidden.discard(obj.hashCode())
    
    def updateBounds(self):
        '''
        Recalculate bounding box
        '''
        self.bbox.invalidate()
        for obj in self.objects:
            if obj.hashCode() in self.hidden:
                continue
            bbox = obj.boundingBox()
            self.bbox.addPoint(bbox.min)
            self.bbox.addPoint(bbox.max)
        
    def add(self, obj, color = None):
        '''
        Add object
        '''
        if color is None:
            color = self.defaultColor
            
        elif isinstance(color, basestring):
            if color.lower() in COLORS:
                color = COLORS[color.lower()]
            else:
                raise OCCError("Unknown color: '%s'" % color)
        
        if isinstance(obj, (occ.Edge, occ.Wire)):
            res = PolylineObj(obj.hashCode())
            res.color = color
            
            tess = obj.tesselate()
            if not tess.isValid():
                return False
                
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
            
            self.drawables.add(res)
            self.objects.add(obj)
            
        elif isinstance(obj, (occ.Face, occ.Solid)):
            if isinstance(obj, occ.Face):
                res = FaceObj(obj.hashCode())
            else:
                res = SolidObj(obj.hashCode())
                
            mesh = obj.createMesh()
            if not mesh.isValid():
                return False
            
            mesh.optimize()
            
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
            tribuffer.loadData(mesh.triangles, triSize*mesh.trianglesItemSize)
            res.triSize = triSize
            
            # create edge indices buffer
            if mesh.nedgeIndices() > 0:
                edgebuffer = res.edgeBuffer = gl.ClientBuffer(gl.ELEMENT_ARRAY_BUFFER)
                res.edgeItemSize = mesh.edgeIndicesItemSize
                edgebuffer.loadData(mesh.edgeIndices, mesh.nedgeIndices()*res.edgeItemSize)
                
                # copy edge range object
                res.range = tuple(mesh.edgeRanges)
                res.rangeSize = mesh.nedgeRanges()
            else:
                res.edgeBuffer = None
                res.range = None
                res.rangeSize = 0
            
            if isinstance(obj, occ.Face):
                # add material
                res.frontMaterial = gl.Material(
                    mode = gl.FRONT,
                    ambient = .3*color,
                    diffuse = color,
                    specular = gl.ColorRGBA(200,200,200,255),
                    shininess = 128.,
                )
                
                res.backMaterial = gl.Material(
                    mode = gl.BACK,
                    ambient = .2*color,
                    diffuse = .7*color,
                    specular = gl.ColorRGBA(100,100,100,255),
                    shininess = 128.,
                )
            else:
                # add material
                res.material = gl.Material(
                    ambient = .3*color,
                    diffuse = color,
                    specular = gl.ColorRGBA(200,200,200,255),
                    shininess = 128.,
                )
            
            self.drawables.add(res)
            self.objects.add(obj)
        
        else:
            raise OCCError('unknown object type')
            
        return True
            
    def onSetup(self):
        self.ui = gl.UI()
        gl.ClearDepth(1.)
        gl.Hint(gl.PERSPECTIVE_CORRECTION_HINT, gl.NICEST)
        gl.Hint(gl.LINE_SMOOTH_HINT, gl.NICEST)
        gl.InitGLExt()
        
        # picking material
        self.pickMat = gl.Material(
            diffuse = self.pickColor,
            ambient = .25*self.pickColor,
            specular = gl.ColorRGBA(255,255,255,255)
        )
        
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
        self.glslFlat = gl.ShaderProgram.flat()
        self.glslPongSpecular = gl.ShaderProgram.pongSpecular(3)
        self.glslPongDiffuse = gl.ShaderProgram.pongDiffuse(3)
        
        # Setup gradient background
        start = .05*self.clearColor
        end = self.clearColor
        
        vertices = array.array('f',(
            0.,0.,0.,
            1.,0.,0.,
            1.,1.,0.,
            0.,1.,0.
        ))
        
        colors = array.array('f',(
            start.red/255., start.green/255., start.blue/255.,
            start.red/255., start.green/255., start.blue/255.,
            end.red/255., end.green/255., end.blue/255.,
            end.red/255., end.green/255., end.blue/255.,
        ))
        
        self.gradientIndices = array.array('B',(
            0, 1, 2,   2, 3, 0,
        ))

        fsize = vertices.itemsize
        buffer = self.gradientBuffer = gl.ClientBuffer()
        buffer.loadData(None, (len(vertices) + len(colors))*fsize)
        
        offset = 0
        size = len(vertices)*fsize
        buffer.setDataType(gl.VERTEX_ARRAY, gl.FLOAT, 3, 0, 0)
        buffer.loadData(vertices, size, offset)
        offset += size
        
        size = len(colors)*fsize
        buffer.setDataType(gl.COLOR_ARRAY, gl.FLOAT, 3, 0, offset)
        buffer.loadData(colors, size, offset)
        
    def onSize(self, w, h):
        self.width, self.height = w - 1, h - 1
        
        if self.width > 1 and self.height > 1:
            # Adjust frustum to viewport aspect
            frustum_aspect = float(self.width) / self.height
            self.cam.setFrustumAspect(frustum_aspect)
            self.cam.setViewportSize(self.width, self.height)
            
            self.makeContextCurrent()
            gl.Viewport(0, 0, self.width, self.height)
            
            self.uiRefresh = True
            self.uiBuffer = None
            
        # initialize
        if not self.initialized:
            self.onSetup()
            self.cam.zoomExtents(self.bbox.min, self.bbox.max)
            self.initialized = True
        
    def onRefresh(self):
        x, y = self.lastPos
        
        if not self.running:
            return
        
        self.makeContextCurrent()
        gl.ClearColor(self.clearColor)
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
        
        if self.uiRefresh:
            # draw gradient
            if self.uiGradient:
                self.onGradient()
            
            # draw 3d objects
            self.onObjects()
            
            if self.uiActive:
                # copy to buffer
                self.uiBuffer.copy()
                
        # draw user interface
        update = self.onUI()
        
        self.onFlushUI()
        self.swapBuffers()
        
        if update:
            self.onRefresh()
    
    def onObjects(self):
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
        
        for obj in self.drawables:
            if obj.hashCode() in self.hidden:
                continue
                
            if isinstance(obj, (SolidObj,FaceObj)):
                # draw mesh
                if self.uiSpecular:
                    glsl = self.glslPongSpecular
                else:
                    glsl = self.glslPongDiffuse
                
                glsl.begin()
                
                gl.Enable(gl.LIGHTING)
                self.light0.enable()
                self.light1.enable()
                self.light2.enable()
        
                gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
                gl.Enable(gl.POLYGON_OFFSET_FILL)
                gl.PolygonOffset(1.,1.)
                    
                obj.buffer.bind()
                obj.triBuffer.bind()
                
                if obj.hashCode() in self.picked:
                    self.pickMat.enable()
                else:
                    if isinstance(obj, FaceObj):
                        obj.frontMaterial.enable()
                        obj.backMaterial.enable()
                    else:
                        obj.material.enable()
                        
                gl.DrawElements(gl.TRIANGLES, obj.triSize, gl.UNSIGNED_INT, 0)
                
                gl.Disable(gl.POLYGON_OFFSET_FILL)
                obj.triBuffer.unBind()
                obj.buffer.unBind()
                glsl.end()
                
                # draw eges
                if self.uiEdges and not obj.edgeBuffer is None:
                    self.glslFlat.begin()
                    gl.Disable(gl.LIGHTING)
                    
                    gl.Color(self.edgeColor)
                    gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
                    gl.Enable(gl.LINE_SMOOTH)
                    gl.LineWidth(1.2)
                    
                    obj.buffer.bind()
                    obj.edgeBuffer.bind()
                    
                    i = 0
                    while i < obj.rangeSize:
                        gl.DrawElements(gl.LINE_STRIP, obj.range[i + 1],
                                        gl.UNSIGNED_INT,
                                        obj.range[i]*obj.edgeItemSize)
                        i += 2
                    
                    gl.Disable(gl.LINE_SMOOTH)
                    obj.edgeBuffer.unBind()
                    obj.buffer.unBind()
                    
                    self.glslFlat.end()
                
            else:
                self.glslFlat.begin()
                
                gl.Disable(gl.LIGHTING)
                
                if obj.hashCode() in self.picked:
                    gl.Color(self.pickColor)
                else:
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
                
                gl.Disable(gl.LINE_SMOOTH)
                gl.LineWidth(1.0)
                
                self.glslFlat.end()
    
    def onPick(self):
        x, y = self.lastPos
        if self.activeUI(x, y):
            return False
        
        self.makeContextCurrent()
        gl.ClearColor(COLORS['white'])
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
        
        gl.Enable(gl.DEPTH_TEST)
        gl.Disable(gl.MULTISAMPLE)
        gl.Disable(gl.DITHER)
        gl.Disable(gl.BLEND)
        gl.Disable(gl.CULL_FACE)
        gl.Disable(gl.LIGHTING)
        
        gl.MatrixMode(gl.PROJECTION)
        self.projectionMatrix.cameraToClip(self.cam)
        gl.LoadMatrixd(self.projectionMatrix)
        
        gl.MatrixMode(gl.MODELVIEW)
        self.modelviewMatrix.worldToCamera(self.cam)
        gl.LoadMatrixd(self.modelviewMatrix)
        
        self.glslFlat.begin()
        
        objmap = {}
        cnt = 1
        color = gl.ColorRGBA()
        
        for obj in self.drawables:
            if obj.hashCode() in self.hidden:
                continue
                
            # set color from counter
            color.fromInt(cnt)
            if color.alpha != 0:
                raise OCCError('to many object to pick')
            color.alpha = 255
            gl.Color(color)
            
            # add object to map
            objmap[cnt] = obj.hashCode()
            cnt += 1
            
            if isinstance(obj, (SolidObj,FaceObj)):
                gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
                
                obj.buffer.bind()
                obj.triBuffer.bind()
                
                gl.DrawElements(gl.TRIANGLES, obj.triSize, gl.UNSIGNED_INT, 0)
                
                obj.triBuffer.unBind()
                obj.buffer.unBind()
            else:
                gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
                gl.LineWidth(5)
                
                obj.buffer.bind()
                
                i = 0
                while i < obj.rangeSize:
                    gl.DrawArrays(gl.LINE_STRIP, obj.range[i], obj.range[i + 1])
                    i += 2
                    
                obj.buffer.unBind()
                gl.LineWidth(1.0)
            
        self.glslFlat.end()
        
        # fetch color under cursor
        pickCol = gl.ReadPixel(x, self.height - y)
        pickCol.alpha = 0
        key = pickCol.toInt()
        
        # clear selection unless shift is presses
        if not self.keyMod == LSHIFT:
            self.picked.clear()
        
        if key in objmap:
            self.picked.add(objmap[key])
            return True
        
        return False
            
    def onGradient(self):
        gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
        gl.Disable(gl.DEPTH_TEST)
        gl.Disable(gl.LIGHTING)
        gl.Enable(gl.DITHER)
        gl.Enable(gl.MULTISAMPLE)
        gl.MatrixMode(gl.PROJECTION)
        gl.LoadIdentity()
        
        gl.Ortho(0,1,0,1,-1,1)
        gl.MatrixMode(gl.MODELVIEW)
        gl.LoadIdentity()
        
        self.gradientBuffer.bind()
        self.glslFlat.begin()
        gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_BYTE, self.gradientIndices)
        self.glslFlat.end()
        self.gradientBuffer.unBind()
    
    def onUIHelp(self):
        ui = self.ui
        update = False
        w, h = self.width, self.height
        x, y = self.lastPos
        
        ui.beginFrame(x,h - y,self.currentButton,0)
        W = min(400, w - 50)
        H = min(600, h - 50)
        ui.beginArea("Viewer Help", .5*w - .5*W, .5*h - .5*H, W, H)
        ui.separatorLine()
        ui.label('Mouse')
        ui.indent()
        ui.label('LMB -> Selection')
        ui.label('LMB + LShift -> Add to Selection')
        ui.label('RMB + Movement -> Rotation')
        ui.label('RMB + LShift + Movement -> Pan')
        ui.label('RMB + LCtrl + Movement -> Zoom')
        ui.label('MWheel -> Zoom (towards mouse target)')
        ui.unindent()
        ui.separator()
        ui.label('Keyboard')
        ui.indent()
        ui.label('ESC -> Quit')
        ui.label('F1 - Toggle Help Text')
        ui.label('Left - Rotate 15 deg around Z axis')
        ui.label('Right - Rotate -15 deg around Z axis')
        ui.label('Up - Rotate 15 deg around camera X axis')
        ui.label('Down - Rotate -15 deg around camera X axis')
        ui.label('PageUp - Zoom In')
        ui.label('PageDown - Zoom Out')
        ui.label('LCtrl + f - Zoom to Extents')
        ui.label('LCtrl + h - Hide selected objects')
        ui.label('LCtrl + H - Show all objects')
        
        if ui.button("OK", True, 5, H - 50, 40):
            self.uiHelp = False
            update = True
        
        ui.endArea()
        ui.endFrame()
        
        return update
    
    def onUIQuit(self):
        ui = self.ui
        update = False
        w, h = self.width, self.height
        x, y = self.lastPos
        
        ui.beginFrame(x,h - y,self.currentButton,0)
        W = min(300, w - 50)
        H = min(150, h - 50)
        ui.beginArea("Dialog", .5*w - .5*W, .5*h - .5*H, W, H)
        ui.separatorLine()
        ui.label('Confirm to quit')
        
        if ui.button("Yes", True, 5, H - 35, 40):
            self.uiQuit = False
            self.running = False
            update = True
        
        elif ui.button("No", True, W - 50, H - 35, 40):
            self.uiQuit = False
            update = True
        
        ui.endArea()
        ui.endFrame()
        
        return update
            
            
    def onUI(self):
        if self.uiQuit:
            return self.onUIQuit()
        
        if self.uiHelp:
            return self.onUIHelp()
            
        ui = self.ui
        update = False
        w, h = self.width, self.height
        x, y = self.lastPos
        
        scroll = self.uiScroll
        if scroll != 0:
            self.uiScroll = 0
            
        ui.beginFrame(x,h - y,self.currentButton,scroll)
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
        
        if ui.check('Gradient background', self.uiGradient, True):
            self.uiGradient = not self.uiGradient
            update = True
        
        if ui.check('Specular material', self.uiSpecular, True):
            self.uiSpecular = not self.uiSpecular
            update = True
        
        if ui.check('Draw face edges', self.uiEdges, True):
            self.uiEdges = not self.uiEdges
            update = True
            
        if ui.button('Take screenshot', True):
            self.onScreenShot()
            
        ui.endScrollArea()
        ui.endFrame()
        
        return update
    
    def onScreenShot(self, prefix = 'screenshot'):
        img = gl.Image(self.width, self.height, gl.RGBA)
        gl.ReadPixels(0, 0, img)
        img.flipY()
        args = prefix, self.screenShotCnt
        img.writePNG('%s%2d.png' % args)
        self.screenShotCnt += 1
            
    def onFlushUI(self):
        # draw gui items
        gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
        gl.Disable(gl.DEPTH_TEST)
        gl.Disable(gl.LIGHTING)
        gl.Disable(gl.DITHER)
        
        gl.MatrixMode(gl.PROJECTION)
        gl.LoadIdentity()
        gl.Ortho(0,self.width,0,self.height,-1,1)
        gl.MatrixMode(gl.MODELVIEW)
        gl.LoadIdentity()
        
        if self.uiActive and not self.uiBuffer is None:
            self.uiBuffer.blit(0,0)
        
        gl.Enable(gl.BLEND)
        gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
        
        self.ui.flush()
    
    def activeUI(self, x, y):
        w, h = self.width, self.height
        y = h - y
        
        if self.ui.anyActive() or self.uiHelp or self.uiQuit:
            return True
        
        if x >= 10 and x <= 200:
            if y >= .4*h and y <= h - 10:
                return True
        
        return False
        
    def onCursorPos(self, x, y):
        width, height = self.width, self.height
        lastx,lasty = self.lastPos  
        cam = self.cam
        
        ui = self.activeUI(x, y)
        viewUpdate = False
        bufferUpdate = False
        
        if ui:
            viewUpdate = True
            if not self.uiActive:
                self.uiActive = True
                self.uiRefresh = True
                
            if self.uiBuffer is None:
                self.uiBuffer = gl.TextureRect2D(width, height, 3)
                self.uiRefresh = True
        else:
            if self.uiActive:
                self.uiActive = False
                viewUpdate = True
                
            if self.currentButton == gl.MOUSE.RIGHT:
                if self.keyMod == LSHIFT:
                    # pan view
                    cam.pan(lastx, lasty, x, y, target = self.mouseCenter)
                    self.uiRefresh = True
                
                elif self.keyMod == LCTRL:
                    x0, y0 = self.mouseStart
                    
                    dy = y0 - y
                    factor = 2.**(dy/128.)
                    
                    self.cam.zoomFactor(factor, self.mouseStart)
                    self.mouseCenter.set(self.cam.target)
                    self.uiRefresh = True
                    
                elif self.keyMod == 0:
                    # rotate view
                    dx = x - lastx
                    dy = y - lasty
                    cam.rotateDeltas(dx, dy, target = self.mouseCenter)
                    self.uiRefresh = True
        
        self.lastPos = x, y
        if viewUpdate or self.uiRefresh:
            self.onRefresh()
        
    def onMouseButton(self, button, action):
        if action == gl.ACTION.PRESS:
            self.currentButton = button
            self.uiRefresh = True
                
            if button == gl.MOUSE.LEFT:
                x, y = self.lastPos  
                if not self.activeUI(x, y):
                    self.onPick()
                
            elif button  == gl.MOUSE.RIGHT:
                self.mouseStart = self.lastPos
                # temporary rotation center to avoid exponential increase
                self.mouseCenter.set(self.cam.target)
                
        else:
            self.currentButton = -1
        
        self.onRefresh()
    
    def onKey(self, key, action):
        cam = self.cam
        
        if action == gl.ACTION.PRESS:
            if key == gl.KEY.ESCAPE:
                self.uiQuit = True
                self.uiRefresh = True
                
            elif key == gl.KEY.F1:
                self.uiHelp = not self.uiHelp
                self.uiRefresh = True
            
            elif key == gl.KEY.LEFT:
                cam.rotate(math.pi/12., geo.Zaxis)
                self.uiRefresh = True
        
            elif key == gl.KEY.RIGHT:
                cam.rotate(-math.pi/12., geo.Zaxis)
                self.uiRefresh = True
        
            elif key == gl.KEY.UP:
                cam.rotate(math.pi/12., cam.X)
                self.uiRefresh = True
           
            elif key == gl.KEY.DOWN:
                cam.rotate(-math.pi/12., cam.X)
                self.uiRefresh = True
            
            elif key == gl.KEY.PAGE_UP:
                x, y = .5*self.width, .5*self.height
                self.cam.zoomFactor(1.15, (x, y))
                self.mouseCenter.set(self.cam.target)
                self.uiRefresh = True
            
            elif key == gl.KEY.PAGE_DOWN:
                x, y = .5*self.width, .5*self.height
                self.cam.zoomFactor(.85, (x, y))
                self.mouseCenter.set(self.cam.target)
                self.uiRefresh = True
            
            elif key == gl.KEY.LEFT_SHIFT:
                self.keyMod |= LSHIFT
            
            elif key == gl.KEY.LEFT_CONTROL:
                self.keyMod |= LCTRL
        else:
            if key == gl.KEY.LEFT_SHIFT:
                self.keyMod ^= LSHIFT
            
            elif key == gl.KEY.LEFT_CONTROL:
                self.keyMod ^= LCTRL
                    
        if self.uiRefresh:
            self.onRefresh()
        
    def onChar(self, ch):
        if self.keyMod & LCTRL:
            if ch == 'f':
                self.onZoomExtents()
                self.mouseCenter.set(self.cam.target)
                self.uiRefresh = True
                self.onRefresh()
            
            elif ch == 'h':
                if self.picked:
                    self.hidden.update(self.picked)
                    self.updateBounds()
                    self.picked.clear()
                    self.uiRefresh = True
                    self.onRefresh()
            
            elif ch == 'H':
                self.hidden.clear()
                self.updateBounds()
                self.uiRefresh = True
                self.onRefresh()
            
    def onScroll(self, scx, scy):
        x, y = self.lastPos
        self.uiScroll = -int(scy)
        
        if not self.activeUI(x, y):
            delta = 1e-4*scy
            dx = delta*self.width
            dy = delta*self.height
            
            self.cam.zoomFactor(1. + max(dx,dy), (x, y))
            self.mouseCenter.set(self.cam.target)
            self.uiRefresh = True
            
        self.onRefresh()
        
    def onClose(self):
        self.uiQuit = True
        return False
        
    def onZoomExtents(self):
        self.cam.zoomExtents(self.bbox.min, self.bbox.max)
        self.mouseCenter.set(self.cam.target)
    
    def onTopView(self):
        self.cam.setTopView()
        self.onZoomExtents()
        
    def onBottomView(self):
        self.cam.setBottomView()
        self.onZoomExtents()
    
    def onLeftView(self):
        self.cam.setLeftView()
        self.onZoomExtents()
    
    def onRightView(self):
        self.cam.setRightView()
        self.onZoomExtents()
    
    def onFrontView(self):
        self.cam.setFrontView()
        self.onZoomExtents()
    
    def onBackView(self):
        self.cam.setBackView()
        self.onZoomExtents()
    
    def onIsoView(self):
        self.cam.setIsoView()
        self.onZoomExtents()

def viewer(objs, colors = None, interactive = False, logger = sys.stderr):
    '''
    Viewer
    
    :objs: Single object or sequence of objects.
    :colors: Color or sequence of colors. Defaults to COLORS.
             The object color is cycled from the seqence or set to single color.
    :interactive: Install input hook for interactive use. Note that the
                  returned reference to the viewer must be referenced to
                  keep the viewer alive.
    :logger: File to write error messages to. Defaults to stderr.
    '''
    if not isinstance(objs, (tuple,list)):
       objs = (objs,)
    
    if not colors is None:
        if not isinstance(colors, (tuple,list)):
            colors = (colors,)
    else:
        colors = COLORS
        
    mw = Viewer(
        title = "Viewer (F1 for help)"
    )
    
    for obj, color in itertools.izip(objs, itertools.cycle(colors)):
        if obj is None:
            continue
        
        # skip Null objects.
        if obj.isNull():
            print("skipped Null object", file=logger)
            continue
        
        if not mw.add(obj, color):
            print("skipped object", file=logger)
    
    mw.onIsoView()
    mw.running = True
    
    if interactive:
        inputHookManager.enable(mw)
        return mw
    else:
        mw.mainLoop()
    
if __name__ == '__main__':
    #e1 = occ.Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,-1.),radius = .5)
    #f1 = occ.Face().createConstrained(e1, ((0.,.0,-.5),))
    w1 = occ.Wire().createRectangle(width = 1., height = 1., radius = 0.)
    e1 = occ.Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = .25)
    face = occ.Face().createFace((w1, e1))

    viewer((face,))