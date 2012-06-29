
.. contents:: Table of Contents


Introduction
************

These examples are available by executing the demo function.

|   from occmodel import demo
|   demo()

To view the results simply pass a sequece of object or a single object
to the viewer function.

|   from occmodel import viewer
|   viewer(solid)
|   viewer((solid,face,edge))


Arc 3P
******

Create an arc defined by three points.

|   start = Vertex(1.,0.,0.)
|   end = Vertex(-1.,0.,0.)
|   pnt = (0.,1.,0.)
|   edge = Edge().createArc3P(start,end,pnt)


Bezier
******

Create bezier curve

|   start = Vertex(0.,0.,0.)
|   end = Vertex(1.,0.,0.)
|   pnts = ((0.,2.,0.), (1.,1.5,0.))
|   b1 = Edge().createBezier(start,end,pnts)


Boolean
*******

Boolean between two solid spheres

|   s1 = Solid().createSphere((0.,0.,0.),.5)
|   s2 = Solid().createSphere((.25,0.,0.),.5)
|   solid = s1.booleanUnion(s2)


Box
***

Create open box with fillet edges.

|   solid = Solid().createBox((0.,0.,0.),(100.,100.,100.))
|   solid.shell(-5, lambda near,far: near[2] > 50 and far[2] > 50)
|   solid.fillet(2., lambda near,far: True)


Circle
******

Create circle curve.

   e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)


Extrude
*******

Extrude face along vector.

|   start = None
|   end = None
|   pnts = ((0.,0.,0.),(0.,2.,0.), (5.,1.5,0.))
|   e1 = Edge().createSpline(start,end,pnts)
|
|   face = Face().createFace(e1)
|
|   solid = Solid().extrude(face, (0.,0.,0.), (0.,0.,5.))


Face interior point
*******************

Create face from circle edge and interior point.

|   e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
|   face = Face().createFace(e1, ((0.,.5,.25),))


Face edge sequence
******************

Create face from sequence of edges.

|   start = Vertex(1.,0.,0.)
|   end = Vertex(-1.,0.,0.)
|   e1 = Edge().createLine(end,start)
|
|   pnt = (0.,1.,0.)
|   e2 = Edge().createArc3P(start,end,pnt)
|
|   face = Face().createFace((e1,e2))


Line
****

Create single line.

|   start = Vertex(1.,0.,0.)
|   end = Vertex(-1.,0.,0.)
|   e1 = Edge().createLine(end,start)


Loft
****

Loft through edges.

|   e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
|   e2 = Edge().createEllipse(center=(0.,0.,5.),normal=(0.,0.,1.), rMajor = 2.0, rMinor=1.0)
|   e3 = Edge().createCircle(center=(0.,0.,10.),normal=(0.,0.,1.),radius = 1.0)
|   solid = Solid().loft(((e1,),(e2,),(e3,)))


Pipe
****

Extrude circle along arc edge

|   start = Vertex(0.,0.,0.)
|   end = Vertex(2.,0.,2.)
|   cen = (2.,0.,0.)
|   e1 = Edge().createArc(start,end,cen)
|
|   e2 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
|   f1 = Face().createFace(e2)
|
|   solid = Solid().pipe(f1, (e1,))


Polygonal face
**************

Create a planar polygonal face

|   pnts = ((0.,0.,0.), (0.,2.,0.), (1.,2.,0.), (1.,0.,0.))
|   f1 = Face().createPolygonal(pnts)


Read
****

Read solid from external STEP file.

|   solid = Solid()
|   solid.readSTEP('test.stp')
|   solid.heal()


Revolve
*******

Revolve face to create solid.

|   e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
|   face = Face().createFace(e1)
|
|   solid = Solid().revolve(face, (0.,2.,0.), (1.,2.,0.), 90.)


Section
*******

Create face from plane cutting through solid.

|   solid = Solid()
|   solid.createSphere((1.,2.,3.),.5)
|
|   plane = Plane.fromNormal((1.,2.,3.), (0.,1.,1.))
|   sec = solid.section(plane)


Sphere
******

Create solid sphere

|   solid = Solid()
|   olid.createSphere((1.,2.,3.),.5)


Spline
******

Create a spline curve

|   start = Vertex(0.,0.,0.)
|   end = Vertex(1.,0.,0.)
|   pnts = ((0.,2.,0.), (5.,1.5,0.))
|   s1 = Edge().createSpline(start,end,pnts)


Write
*****

Write to external STEP file.

|   model = Model()
|   model.createSphere(1.,2.,3.,.5)
|   model.writeSTEP('test.stp')
