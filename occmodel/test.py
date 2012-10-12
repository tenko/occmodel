#!/usr/bin/python2
# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#
from math import pi, sin, cos, copysign

from occmodel import *

'''
pnts = ((0.,0.,0.), (0.,2.,0.), (1.,2.,0.), (1.,0.,0.))
f1 = Face().createPolygonal(pnts)
print f1
print f1.area()
'''

'''
start = Vertex(0.,0.,0.)
end = Vertex(1.,0.,0.)
pnts = ((0.,2.,0.), (1.,1.5,0.))
b1 = Edge().createBezier(start,end,pnts)
print b1
print b1.length()

start = None
end = None
pnts = ((0.,0.,0.), (0.,2.,0.), (0.5,1.,0.), (1.,-1.,0.))
b1 = Edge().createBezier(start,end,pnts)
print b1
print b1.length()
'''

'''
start = Vertex(0.,0.,0.)
end = Vertex(1.,0.,0.)
pnts = ((0.,2.,0.), (5.,1.5,0.))
s1 = Edge().createSpline(start,end,pnts)
print s1
print s1.length()
'''

'''
start = None
end = None
pnts = ((0.,0.,0.),(0.,2.,0.), (5.,1.5,0.))
e1 = Edge().createSpline(start,end,pnts)
print e1
print e1.length()

face = Face().createFace(e1)
print face
print face.area()

solid = Solid().extrude(face, (0.,0.,0.), (0.,0.,5.))
print solid
print 'area = ', solid.area()
print 'volume = ', solid.volume()
'''

'''
start = Vertex(1.,0.,0.)
end = Vertex(-1.,0.,0.)
e1 = Edge().createLine(end,start)
print e1
print e1.length()

pnt = (0.,1.,0.)
e2 = Edge().createArc3P(start,end,pnt)
print e2
print e2.length()

face = Face().createFace((e1,e2), ((0.,.5,.5),))
print face
print face.area()

solid = Solid().extrude(face, (0.,0.,0.), (0.,0.,5.))
print solid
print 'area = ', solid.area()
print 'volume = ', solid.volume()
viewer((face, e1), ('red', 'green'))
'''

'''
e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
e2 = Edge().createCircle(center=(0.,0.,5.),normal=(0.,0.,1.),radius = 1.5)
e3 = Edge().createCircle(center=(0.,0.,10.),normal=(0.,0.,1.),radius = 1.0)
solid = Solid().loft((e1,e2,e3), True)
print solid.volume()
#solid.writeSTEP('test.stp')
#viewer(solid)
'''

'''
solid = Solid()
solid.readSTEP('test.stp')
solid.heal()
viewer(solid)
'''

'''
e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
face = Face().createFace(e1)
print face
print face.area()
print face.inertia()

solid = Solid().extrude(face, (0.,0.,0.), (0.,0.,1.))
print solid
print 'area = ', solid.area()
print 'volume = ', solid.volume()
'''

'''
e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
face = Face().createFace(e1)
print face
print face.area()

solid = Solid().revolve(face, (0.,2.,0.), (1.,2.,0.), 90.)
print solid
print 'area = ', solid.area()
print 'volume = ', solid.volume()
'''

'''
model = Model()
model.createSphere(1.,2.,3.,.5)
#model.translate(-1.,-2.,-3.)
model.rotate((0.,0.,0.),(1.,0.,0.), 15.)
model.writeSTEP('test.stp')
print model
'''

'''
solid = Solid()
solid.createSphere((1.,2.,3.),.5)

plane = Plane.fromNormal((1.,2.,3.), (0.,1.,1.))
sec = solid.section(plane)
print 'area = ', sec.area()

viewer(sec)
'''

'''
solid = Solid().createBox((0.,0.,0.),(100.,100.,100.))
solid.shell(-5, lambda near,far: near[2] > 50 and far[2] > 50)
solid.fillet(2., lambda near,far: True)
#solid.writeSTEP('test.stp')
viewer(solid)
'''

'''
s1 = Solid().createSphere((0.,0.,0.),.5)
s2 = Solid().createSphere((.25,0.,0.),.5)

#s1.booleanUnion(s2)
#s1.booleanDifference(s2)
s1.booleanIntersection(s2)
#s1.writeSTEP('test.stp')
print s1.volume()
'''

'''
s1 = Solid().createSphere((0.,0.,0.),.5)
print s1.centreOfMass()
s1.translate((1.,0.,0.))
print s1.centreOfMass()
'''

'''
s1 = Solid().createSphere((0.,0.,0.),.5)
print s1.volume()
s2 = Solid().createSphere((2.,0.,0.),.5)
print s2.volume()
s3 = Solid().addSolids((s1,s2))
print s3.volume()
'''

'''
sp1 = Solid().createSphere((0.,0.,0.),.5)
print sp1.volume()
sp2 = sp1.copy()
print sp1.volume()
sp2.translate((.5, 0., 0.))
#sp2.scale((.5, 0., 0.), 1.25)
sp2.rotate((0.,-1.,0.),(0.,1.,0.),10.)
sp1.booleanDifference(sp2)
'''

'''
sp1 = Solid().createCylinder((0.,0.,0.),(0.,0.,1.), 1.)
print sp1.volume()
'''

'''
sp1 = Solid().createTorus((0.,0.,0.),(0.,0.,1.), 1., 2.)
print sp1.volume()
'''

'''
c1 = Solid().createCone((0.,0.,0.),(0.,0.,1.), 1., 2.)
print c1.volume()
'''

'''
b1 = Solid().createBox((0.,0.,0.),(1.,1.,1.))
print b1.volume()
'''

'''
b1 = Solid().createBox((0.,0.,0.),(1.,1.,1.))
print b1.volume() 
b1.fillet(.25, lambda start,end: start[2] > .5 and end[2] > .5)
print b1.volume()
'''

'''
start = Vertex(0.,0.,0.)
end = Vertex(1.,0.,1.)
cen = (1.,0.,0.)
e1 = Edge().createArc(start,end,cen)

e2 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
face = Face().createFace(e2)

s1 = Solid().pipe(face, e1)
print s1.volume()
'''

'''
p1 = Vertex(0.,0.,0.)
p2 = Vertex(1.,0.,0.)
p3 = Vertex(1.,1.,0.)
p4 = Vertex(0.,1.,0.)
e1 = Edge().createLine(p1,p2)
e2 = Edge().createLine(p2,p3)
e3 = Edge().createLine(p3,p4)
e4 = Edge().createLine(p4,p1)

face = Face().createFace((e1,e2,e3,e4))
print face.centreOfMass()
mesh = face.createMesh(0.1,.5)
print mesh
'''

'''
#solid = Solid().createSphere((0.,0.,0.),.5)
solid = Solid().createBox((0.,0.,0.),(1.,1.,1.))
mesh = solid.createMesh(0.1,.5)
print mesh
print mesh.vertex(0)
print mesh.normal(0)
print mesh.triangle(0)
'''

'''
start = Vertex(1.,0.,0.)
end = Vertex(-1.,0.,0.)
pnt = (0.,1.,0.)
e1 = Edge().createArc3P(start,end,pnt)
print e1.boundingBox()
pnts = e1.tesselate()
print pnts
'''

'''
e1 = Edge().createHelix(.5, 2., 1.0, 0.)
print e1.length()
print e1.start
print e1.end
'''

'''
p1 = Vertex(0.,0.,0.)
p2 = Vertex(1.,0.,0.)
p3 = Vertex(1.,1.,0.)
p4 = Vertex(0.,1.,0.)
e1 = Edge().createLine(p1,p2)
e2 = Edge().createLine(p2,p3)
e3 = Edge().createLine(p3,p4)
e4 = Edge().createLine(p4,p1)
w1 = Wire().createWire((e1,e2,e3,e4))
print w1.length()
f1 = Face().createFace(w1)
print f1.area()
'''

'''
e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
e2 = Edge().createEllipse(center=(0.,0.,5.),normal=(0.,0.,1.), rMajor = 2.0, rMinor=1.0)
e3 = Edge().createCircle(center=(0.,0.,10.),normal=(0.,0.,1.),radius = 1.0)
solid = Solid().loft((e1,e2,e3), False)
print solid.volume()
'''

'''
rect = Wire().createRectangle(height = 2., radius = .5)
print rect.length()
'''

'''
w1 = Wire().createRegularPolygon()
print w1.length()
f1 = Face().createFace(w1)
print f1.area()
'''

'''
e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
plane = Plane()
print e1.hasPlane(plane = plane)
print plane
'''

'''
solid = Solid().createBox((0.,0.,0.),(1.,1.,1.))
e1 = Edge().createCircle(center=(0.5,0.,.5),normal=(0.,0.,1.),radius = 0.25)
e2 = Edge().createCircle(center=(0.5,0.5,1.),normal=(0.,0.,1.),radius = 0.1)
w1 = Wire().createWire(e2)
e3 = Edge().createCircle(center=(1.0,0.5,1.),normal=(0.,0.,1.),radius = 0.25)
f1 = Face().createFace(e3)
solid.cut((e1,w1,f1))
'''

'''
e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
e2 = Edge().createCircle(center=(0.,0.,.5),normal=(0.,0.,1.),radius = 1.5)
v1 = Vertex(0.,0.,1.)
solid = Solid().loft((e1,e2,v1))
print solid.volume()
'''

'''
w1 = Wire().createPolygon((
    (0.,0.,0.),
    (0.,0.,5.),
    (5.,0.,5.)),
    close = False
)

e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
solid = Solid().sweep(w1, e1, cornerMode = SWEEP_RIGHT_CORNER)
print solid.volume()
'''

'''
w1 = Wire().createPolygon((
    (0.,0.,0.),
    (1.,0.,0.),
    (.5,1.,0.)),
    close = True
)
f1 = Face().createFace(w1)
e1 = Edge().createCircle(center=(.5,.5,-1.),normal=(0.,0.,1.),radius = .15)
f1.booleanIntersection(e1)
#f1.booleanDifference(e1)
solid = Solid().extrude(f1, (0.,0.,0.), (0.,0.,1.))
solid.createMesh()
'''
'''
w1 = Wire().createPolygon((
    (0.,0.,0.),
    (0.,0.,5.),
    (5.,0.,5.)),
    close = False
)

e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
solid = Solid().sweep(w1, e1, cornerMode = SWEEP_RIGHT_CORNER)
print solid.volume()
'''

'''
start = Vertex(0.,0.,0.)
end = Vertex(1.,0.,1.)
cen = (1.,0.,0.)
e1 = Edge().createArc(start,end,cen)

e2 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
face = Face().createFace(e2)
e3 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = .8)
face.cut(e3)

s1 = Solid().pipe(face, e1)
print s1.volume()
'''

'''
start = Vertex(0.,0.,0.)
end = Vertex(1.,0.,1.)
cen = (1.,0.,0.)
e1 = Edge().createArc(start,end,cen)

start = Vertex(0.,1.,0.)
end = Vertex(2.,1.,2.)
cen = (2.,1.,0.)
e2 = Edge().createArc(start,end,cen)

face = Face().loft((e1,e2))
print face.isValid()
'''

'''
start = Vertex(0.,0.,0.)
end = Vertex(1.,0.,1.)
cen = (1.,0.,0.)
e1 = Edge().createArc(start,end,cen)

e2 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)

face = Face().sweep(e2, e1)
print face.isValid()
'''

'''
e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
e2 = Edge().createCircle(center=(-1.,0.,0.),normal=(0.,0.,1.),radius = .5)
e3 = Edge().createCircle(center=(1.,0.,0.),normal=(0.,0.,1.),radius = .5)
w1 = Wire().createWire(e1)
print w1.length()
w1.cut((e2,e3))
print w1.length()
'''

'''
face = Face().createPolygonal(((0.,0.,0.),(1.,1.,0.),(1.,1.,1.),(0.,0.,1.)))
e1 = Edge().createCircle(center=(.5,0.2,.5),normal=(0.,1.,0.),radius = .25)
w1 = Wire().createWire(e1)
w1.project(face)
print w1.isValid()
'''

'''
p1 = Vertex(0.,0.,0.)
p2 = Vertex(1.,0.,0.)
p3 = Vertex(1.,1.,0.)
e1 = Edge().createLine(p1,p2)
e2 = Edge().createLine(p2,p3)
w1 = Wire().createWire((e1,e2))
#face = Face().extrude(w1, (0.,0.,0.),(0.,0.,1.))
face = Face().revolve(w1, (0.,0.,0.),(0.,1.,0.), 90.)
print face.isValid()
#print face.typeName()
#Tools.writeSTEP('test.stp', face)
'''
#solid = Solid()
#solid.createSphere((1.,2.,3.),.5)
#print solid.shapeType()
#Tools.writeSTEP('test.stp', solid)
#Tools.writeBREP('test.brp', solid)
#Tools.writeSTL('test.stl', solid)
#Tools.writeVRML('test.wrl', solid)
print Tools.readSTEP('test.stp')