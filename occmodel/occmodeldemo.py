#!/usr/bin/python2
# -*- coding: utf-8 -*-
import sys
import math

import geotools as geo
import gltools as gl
import occmodel as occ
from occmodelviewer import Viewer

class Demo:
    @classmethod
    def eval(self):
        loc = {
            'pi':math.pi,
            'Vertex':occ.Vertex,
            'Edge':occ.Edge,
            'Wire':occ.Wire,
            'Face':occ.Face,
            'Solid':occ.Solid,
            'SWEEP_RIGHT_CORNER': occ.SWEEP_RIGHT_CORNER,
        }
        if sys.hexversion > 0x03000000:
            exec(self.TEXT, loc)
        else:
            exec(self.TEXT) in loc
            
        return self.results(loc)
        
class Edge_1(Demo):
    NAME = "Primitives" 
    TEXT = \
"""
e1 = Edge().createLine(start = (0.,0.,0.), end = (1.,1.,0.))

e2 = Edge().createCircle(center = (0.,.5,0.), normal = (0.,0.,1.), radius = .5)

e3 = Edge().createArc(start = (-.5,0.,0.), end = (.5,1.,0.), center = (.5,0.,0.))

e4 = Edge().createArc3P(start = (1.,0.,0.), end = (-1.,0.,0.), pnt = (0.,1.,0.))

e5 = Edge().createEllipse(center=(0.,0.,0.),normal=(0.,0.,1.), rMajor = .5, rMinor=.2)

e6 = Edge().createHelix(pitch = .5, height = 1., radius = .25, angle = pi/5.)

pnts = ((0.,0.,0.), (0.,1.,0.), (1.,.5,0.), (1.,0.,0.))
e7 = Edge().createBezier(points = pnts)

pnts = ((0.,0.,0.), (0.,.5,0.), (1.,.25,0.),(1.,0.,0.))
e8 = Edge().createSpline(points = pnts)
"""
    
    @classmethod
    def results(self, loc):
        ret = []
        
        x,y = 0.,2.
        for name in ('e1','e2','e3','e4'):
            e = loc[name]
            e.translate((x,y,0))
            ret.append(e)
            x += 1.5
        
        x,y = 0.,0.
        for name in ('e5','e6','e7','e8'):
            e = loc[name]
            e.translate((x,y,0))
            ret.append(e)
            x += 1.5
            
        return ret

class Wire_1(Demo):
    NAME = "Primitives" 
    TEXT = \
"""
w1 = Wire().createRectangle(width = 1., height = 0.75, radius = 0.)

w2 = Wire().createRectangle(width = 1., height = 0.75, radius = .25)

w3 = Wire().createPolygon((
    (-.5,-.5,0.),
    (.5,-.5,0.),
    (0.,.5,0.)),
    close = True,
)

w4 = Wire().createRegularPolygon(radius = .5, sides = 6.)
"""
    
    @classmethod
    def results(self, loc):
        ret = []
        
        x,y = 0.,0.
        for name in ('w1','w2','w3','w4'):
            e = loc[name]
            e.translate((x,y,0))
            ret.append(e)
            x += 1.5
            
        return ret

class Wire_2(Demo):
    NAME = "Operations" 
    TEXT = \
"""
# offset wire
w1 = Wire().createRectangle(width = 1., height = 0.75, radius = 0.)

w2 = Wire().createRectangle(width = 1., height = 0.75, radius = 0.)
w2.offset(0.1)

# fillet all edges
w3 = Wire().createRegularPolygon(radius = .5, sides = 6.)
w3.fillet(0.2)

# chamfer all edges
w4 = Wire().createRectangle(width = 1., height = 0.75, radius = 0.)
w4.chamfer(0.15)

# wire boolean cut operation
w5 = Wire().createRectangle(width = 1., height = 1., radius = 0.)
e1 = Edge().createCircle(center=(-.5,-.5,0.),normal=(0.,0.,1.),radius = .35)
e2 = Edge().createEllipse(center=(.5,.5,0.),normal=(0.,0.,1.), rMajor = .75, rMinor=.35)
w5.cut((e1,e2))

# wire boolean common operation
w6 = Wire().createRectangle(width = 1., height = 1., radius = 0.)
e2 = Edge().createEllipse(center=(-.5,-.5,0.),normal=(0.,0.,1.), rMajor = .75, rMinor=.35)
e2.rotate(-pi/.6, (0.,0.,1.), (-.5,-.5,0.))
w6.common(e2)
"""
    
    @classmethod
    def results(self, loc):
        ret = [loc['w1'], loc['w2']]
        
        x,y = 1.5,0.
        for name in ('w3','w4','w5', 'w6'):
            e = loc[name]
            e.translate((x,y,0))
            ret.append(e)
            x += 1.5
            
        return ret
        
class Face_1(Demo):
    NAME = "Create 1" 
    TEXT = \
"""
# create planar face from outer wire and edges/wires defining hole
w1 = Wire().createRectangle(width = 1., height = 1., radius = 0.)
e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = .25)
f1 = Face().createFace((w1, e1))

# create a face constrained by circle and points
e2 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = .5)
f2 = Face().createConstrained(e2, ((0.,.0,.25),))

# create planar polygonal face from series of points
pnts = ((-.5,-.5,0.), (0.,.5,0.), (1.,.5,0.), (.5,-.5,0.))
f3 = Face().createPolygonal(pnts)
"""
    
    @classmethod
    def results(self, loc):
        ret = []
        
        x,y = 0.,0.
        for name in ('f1','f2','f3'):
            e = loc[name]
            e.translate((x,y,0))
            ret.append(e)
            x += 1.5
            
        return ret

class Face_2(Demo):
    NAME = "Create 2" 
    TEXT = \
"""
# create face by extruding edge/wire
e1 = Edge().createArc(start = (-.5,-.25,0.), end = (.5,.75,0.),
                      center = (.5,-.25,0.))
f1 = Face().extrude(e1, (0.,0.,0.), (0.,0.,1.))

# create face by revolving edge
pnts = ((0.,0.,0.), (0.,1.,0.), (1.,.5,0.), (1.,0.,0.))
e2 = Edge().createBezier(points = pnts)
f2 = Face().revolve(e2, (0.,-1.,0.), (1.,-1.,0.), pi/2.)

# create face by sweeping edge along spine
e3 = Edge().createArc((0.,0.,0.), (1.,0.,1.), (1.,0.,0.))
e4 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = .25)
f3 = Face().sweep(e3, e4)

# create face by lofting through edges
e5 = Edge().createArc((0.,0.,0.),(1.,0.,1.),(1.,0.,0.))
e6 = Edge().createArc((0.,1.,0.),(2.,1.,2.),(2.,1.,0.))
f4 = Face().loft((e5,e6))
"""
    
    @classmethod
    def results(self, loc):
        ret = []
        
        x,y = 0.,0.
        for name in ('f1','f2','f3','f4'):
            e = loc[name]
            e.translate((x,y,0))
            ret.append(e)
            x += 1.5
            
        return ret

class Face_3(Demo):
    NAME = "Create 3" 
    TEXT = \
"""
# cut face by edge
e1 = Edge().createArc(start = (-.5,-.25,0.), end = (.5,.75,0.), center = (.5,-.25,0.))
f1 = Face().extrude(e1, (0.,0.,0.), (0.,0.,1.))
e2 = Edge().createCircle(center=(.5,.5,0.),normal=(0.,1.,0.),radius = .75)
f1.cut(e2)

# find common face between circulare face and ellipse
e3 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = .5)
f2 = Face().createFace(e3)
e4 = Edge().createEllipse(center=(0.,0.,0.),normal=(0.,0.,1.), rMajor = .75, rMinor=.3)
f2.common(e4)
"""
    
    @classmethod
    def results(self, loc):
        ret = []
        
        x,y = 0.,0.
        for name in ('f1','f2'):
            e = loc[name]
            e.translate((x,y,0))
            ret.append(e)
            x += 1.5
            
        return ret

class Solid_1(Demo):
    NAME = "Primitives" 
    TEXT = \
"""
# solid sphere from center and radius
s1 = Solid().createSphere((0.,0.,0.),.5)

# solid cylinder from two points and radius
s2 = Solid().createCylinder((0.,0.,0.),(0.,0.,1.), .25)

# solid torus from two points defining axis, ring radius and radius.
s3 = Solid().createTorus((0.,0.,0.),(0.,0.,.1), .5, .1)

# solid cone from two points defining axis and upper and lower radius
s4 = Solid().createCone((0.,0.,0.),(0.,0.,1.), .2, .5)

# solid box from two points defining diagonal of box
s5 = Solid().createBox((-.5,-.5,-.5),(.5,.5,.5))
"""
    
    @classmethod
    def results(self, loc):
        ret = []
        
        x,y = 0.,0.
        for name in ('s1','s2','s3','s4','s5'):
            e = loc[name]
            e.translate((x,y,0))
            ret.append(e)
            x += 1.5
            
        return ret

class Solid_2(Demo):
    NAME = "Create 1" 
    TEXT = \
"""
# create solid by extruding face
e1 = Edge().createLine((-.5,0.,0.),(.5,0.,0.))
e2 = Edge().createArc3P((.5,0.,0.),(-.5,0.,0.),(0.,.5,0.))
w1 = Wire().createWire((e1,e2))
f1 = Face().createFace(w1)
s1 = Solid().extrude(f1, (0.,0.,0.), (0.,0.,1.))

# create solid by revolving face
e2 = Edge().createEllipse(center=(0.,0.,0.),normal=(0.,0.,1.), rMajor = .5, rMinor=.2)
f2 = Face().createFace(e2)
s2 = Solid().revolve(f2, (1.,0.,0.), (1.,1.,0.), pi/2.)

# create solid by sweeping wire along wire path
w1 = Wire().createPolygon((
    (0.,0.,0.),
    (0.,0.,1.),
    (.75,0.,1.),
    (.75,0.,0.)),
    close = False
)
e3 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = .2)
s3 = Solid().sweep(w1, e3, cornerMode = SWEEP_RIGHT_CORNER)

# create solid by lofting through edges, wires and optional start/end vertex.
e4 = Edge().createCircle(center=(.25,0.,0.),normal=(0.,0.,1.),radius = .25)
e5 = Edge().createCircle(center=(.25,0.,.5),normal=(0.,0.,1.),radius = .5)
v1 = Vertex(.25,0.,1.)
s4 = Solid().loft((e4,e5,v1))

# create solid by sweeping face along path
e6 = Edge().createHelix(.4, 1., .4)
e7 = Edge().createCircle(center=(.5,0.,0.),normal=(0.,1.,0.),radius = 0.1)
f3 = Face().createFace(e7)
s5 = Solid().pipe(f3, e6)
"""
    
    @classmethod
    def results(self, loc):
        ret = []
        
        x,y = 0.,0.
        for name in ('s1','s2','s3','s4','s5'):
            e = loc[name]
            e.translate((x,y,0))
            ret.append(e)
            x += 1.5
            
        return ret

class Solid_3(Demo):
    NAME = "Create 2" 
    TEXT = \
"""
# fuse solids
s1 = Solid().createBox((0.,0.,0.),(.5,.5,.5))
s2 = Solid().createBox((.25,.25,.25),(.75,.75,.75))
s1.fuse(s2)

# modifying solid by cutting against edge,wire,face or solid.
# Edge and wire always cut through, but Face only cuts in the
# direction of the normal.
s2 = Solid().createBox((0.,0.,0.),(1.,1.,1.))
e1 = Edge().createCircle(center=(0.5,0.5,1.),normal=(0.,0.,1.),radius = 0.1)
e2 = Edge().createCircle(center=(.5,0.,.5),normal=(0.,0.,1.),radius = 0.25)
f1 = Face().createFace(e2)
s3 = Solid().createSphere((1.,1.,1.),.35)
s2.cut((e1,f1,s3))

# find common shape
s4 = Solid().createSphere((.5,.5,0.),.75)
s5 = Solid().createCylinder((.5,.5,-1),(0.,.5,1.), .5)
s4.common(s5)

# fillet edges
s6 = Solid().createBox((0.,0.,0.),(1.,1.,1.))
s6.fillet(.2)

# chamfer edges
s7 = Solid().createBox((0.,0.,0.),(1.,1.,1.))
s7.chamfer(.2)

# shell operation
s8 = Solid().createBox((0.,0.,0.),(1.,1.,1.))
s8.shell(-.1)

# offset face to create solid
e3 = Edge().createArc((0.,0.,0.),(.5,0.,.5),(.5,0.,0.))
e4= Edge().createArc((0.,.5,0.),(1.,.5,1.),(1.,.5,0.))
f2 = Face().loft((e3,e4))
s9 = Solid().offset(f2, 0.2)
"""
    
    @classmethod
    def results(self, loc):
        ret = []
        
        x,y = 0.,0.
        for name in ('s1','s2','s4','s6','s7','s8','s9'):
            e = loc[name]
            e.translate((x,y,0))
            ret.append(e)
            x += 1.5
            
        return ret

class Solid_4(Demo):
    NAME = "Create 3" 
    TEXT = \
"""
# create solid by sewing together faces
e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,-1.),radius = .5)
f1 = Face().createConstrained(e1, ((0.,.0,-.5),))

e2 = Edge().createCircle(center=(0.,0.,1.),normal=(0.,0.,1.),radius = .5)
f2 = Face().createConstrained(e2, ((0.,.0,1.5),))

f3 = Face().loft((e1,e2))

s1 = Solid().createSolid((f1,f3,f2))

# create solid from TrueType font
s2 = Solid().createText(1., .25, 'Tenko')
"""
    
    @classmethod
    def results(self, loc):
        ret = []
        
        x,y = 0.,0.
        for name in ('s1','s2'):
            e = loc[name]
            e.translate((x,y,0))
            ret.append(e)
            x += 1.5
            
        return ret

class DemoViewer(Viewer):
    def __init__(self, fullscreen = False):
        title = "Demo (F1 for help - 'm' to toggle menu)"
        Viewer.__init__(self, -1, -1, title, fullscreen)
        
        self.uiView = False
        self.uiDemo = True
        self.showUI = True
        self.source = ''
        
        self.defaultColor = gl.ColorRGBA(100,100,100,255)
        self.edgeColor = gl.ColorRGBA(255,255,255,255)
        
    def activeUI(self, x, y):
        w, h = self.width, self.height
        y = h - y
        
        if not self.showUI:
            return False
        
        if self.ui.anyActive() or self.uiHelp:
            return True
        
        if x >= 10 and x <= 200:
            if y >= .4*h and y <= h - 10:
                return True
        
        if self.source and x >= .5*w and x < w - 10:
            if y >= 10 and y <= 160:
                return True
                
        return False
        
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
            
        if not self.showUI:
            # empty gui
            ui.beginFrame(x,h - y,self.currentButton,scroll)
            ui.endFrame()
            return update
        
        ui.beginFrame(x,h - y,self.currentButton,scroll)
        
        ui.beginScrollArea("Menu", 10, .4*h, 200, .6*h - 10)
        ui.separatorLine()
        
        if ui.collapse("View settings", "", self.uiView, True):
            self.uiView = not self.uiView
        
        if self.uiView:
            ui.indent()
            
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
                self.onScreenShot(prefix = 'demoShot')
            
            ui.unindent()
            ui.separatorLine()
        
        if ui.collapse("Demos", "", self.uiDemo, True):
            self.uiDemo = not self.uiDemo
        
        if self.uiDemo:
            ui.indent()
            
            ui.label("Edges")
            ui.indent()
            if ui.item(Edge_1.NAME, True):
                self.onSetDemo(Edge_1)
                update = True
            
            ui.unindent()
            
            ui.label("Wires")
            ui.indent()
            if ui.item(Wire_1.NAME, True):
                self.onSetDemo(Wire_1)
                update = True
            
            if ui.item(Wire_2.NAME, True):
                self.onSetDemo(Wire_2)
                update = True
                
            ui.unindent()
            
            ui.label("Faces")
            ui.indent()
            if ui.item(Face_1.NAME, True):
                self.onSetDemo(Face_1)
                update = True
            
            if ui.item(Face_2.NAME, True):
                self.onSetDemo(Face_2)
                update = True
            
            if ui.item(Face_3.NAME, True):
                self.onSetDemo(Face_3)
                update = True
                
            ui.unindent()
            
            ui.label("Solids")
            ui.indent()
            if ui.item(Solid_1.NAME, True):
                self.onSetDemo(Solid_1)
                update = True
            
            if ui.item(Solid_2.NAME, True):
                self.onSetDemo(Solid_2)
                update = True
            
            if ui.item(Solid_3.NAME, True):
                self.onSetDemo(Solid_3)
                update = True
            
            if ui.item(Solid_4.NAME, True):
                self.onSetDemo(Solid_4)
                update = True
            
            ui.indent()
        
        ui.endScrollArea()
        
        if self.source:
            ui.beginScrollArea("Source", .5*w, 10, .5*w - 10, 150.)
            for line in self.source.splitlines():
                if not line.strip():
                    ui.separator()
                    continue
                ui.label(line)
            ui.endScrollArea()
            
        ui.endFrame()
        return update
    
    def onSetDemo(self, demo):
        self.source = demo.TEXT.strip()
        
        self.bbox.invalidate()
        self.clear()
        for obj in demo.eval():
            self.add(obj)
        
        self.onIsoView()
            
    def onChar(self, ch):    
        if ch == 'm':
            self.showUI = not self.showUI
            self.onRefresh()
        
        Viewer.onChar(self, ch)
    
def main():
    mw = DemoViewer()
    mw.onIsoView()
    mw.mainLoop()
    
if __name__ == '__main__':
    main()
    