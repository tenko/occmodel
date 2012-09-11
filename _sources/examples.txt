Introduction
============

Examples are available by executing the demo
function.

.. code-block:: python

    from occmodel import demo
    demo()

.. figure:: images/demo_window.jpg
    
    Demo window.
    
To view geometrical objects simply pass a sequece of object or a single
object to the viewer function.

.. code-block:: python

    from occmodel import viewer
    viewer(solid)
    viewer((solid,face,edge))

Geometry
========

**Vertex** are 3d point objects which are used to reference start and end
points of edges in order to properly join edges.

**Edge** are 3d curves which form border of faces. Closed edges like
circles and ellipsis does not need to define start and end points to
be valid.

**Face** are 3d surfaces which can be lofted, extruded etc. to form
solids objects. Faces are created from 

**Solid** are the main object which contain rich functionalty to
combine and edit solid objects.

Point and vectors passed to the geometry functions can be any valid
python sequence of three numbers (Ref: Vector and Point classes)

Edges
=====

Line
----

Create single line.

.. code-block:: python

    start = Vertex(1.,0.,0.)
    end = Vertex(-1.,0.,0.)
    e1 = Edge().createLine(end,start)
    
Arc 3P
------

Create an arc defined by three points.

.. code-block:: python

    start = Vertex(1.,0.,0.)
    end = Vertex(-1.,0.,0.)
    pnt = (0.,1.,0.)
    edge = Edge().createArc3P(start,end,pnt)

Circle
------

Create circle curve.

.. code-block:: python

    e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
    
Bezier
------

Create bezier curve

.. code-block:: python

    start = Vertex(0.,0.,0.)
    end = Vertex(1.,0.,0.)
    pnts = ((0.,2.,0.), (1.,1.5,0.))
    b1 = Edge().createBezier(start,end,pnts)

Spline
------

Create a spline curve

.. code-block:: python

    start = Vertex(0.,0.,0.)
    end = Vertex(1.,0.,0.)
    pnts = ((0.,2.,0.), (5.,1.5,0.))
    s1 = Edge().createSpline(start,end,pnts)

Faces
=====

Face interior point
-------------------

Create face from circle edge and interior point.

.. code-block:: python

    e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
    face = Face().createFace(e1, ((0.,.5,.25),))

Face edge sequence
------------------

Create face from sequence of edges.

.. code-block:: python

    start = Vertex(1.,0.,0.)
    end = Vertex(-1.,0.,0.)
    e1 = Edge().createLine(end,start)
    
    pnt = (0.,1.,0.)
    e2 = Edge().createArc3P(start,end,pnt)
    
    face = Face().createFace((e1,e2))

Polygonal face
--------------

Create a planar polygonal face

.. code-block:: python

    pnts = ((0.,0.,0.), (0.,2.,0.), (1.,2.,0.), (1.,0.,0.))
    f1 = Face().createPolygonal(pnts)

Section
-------

Create face from plane cutting through solid.

.. code-block:: python

    solid = Solid()
    solid.createSphere((1.,2.,3.),.5)
    
    plane = Plane.fromNormal((1.,2.,3.), (0.,1.,1.))
    sec = solid.section(plane)
    
Solids
======

Primitive Solids
-----------------

Create sphere primitive.

.. code-block:: python

    solid = Solid()
    solid.createSphere((1.,2.,3.),.5)

Create box primitive.

.. code-block:: python

    solid = Solid().createBox((0.,0.,0.),(100.,100.,100.))

Create cylinder primitive.

.. code-block:: python

    solid = Solid().createCylinder((0.,0.,0.),(0.,0.,1.), 1.)

Create torus primitive.

.. code-block:: python

    solid = Solid().createTorus((0.,0.,0.),(0.,0.,1.), 1., 2.)

Create cone primitive.

.. code-block:: python

    solid = Solid().createCone((0.,0.,0.),(0.,0.,1.), 1., 2.)

Boolean
-------

Boolean union between two solid spheres.

.. code-block:: python

    s1 = Solid().createSphere((0.,0.,0.),.5)
    s2 = Solid().createSphere((.25,0.,0.),.5)
    solid = s1.booleanUnion(s2)

Boolean difference between two solid spheres.

.. code-block:: python

    s1 = Solid().createSphere((0.,0.,0.),.5)
    s2 = Solid().createSphere((.25,0.,0.),.5)
    solid = s1.booleanDifference(s2)

Boolean intersection between two solid spheres.

.. code-block:: python

    s1 = Solid().createSphere((0.,0.,0.),.5)
    s2 = Solid().createSphere((.25,0.,0.),.5)
    solid = s1.booleanIntersection(s2)
    
Extrude
-------

Extrude face along vector.

.. code-block:: python

    start = None
    end = None
    pnts = ((0.,0.,0.),(0.,2.,0.), (5.,1.5,0.))
    e1 = Edge().createSpline(start,end,pnts)
    
    face = Face().createFace(e1)
    
    solid = Solid().extrude(face, (0.,0.,0.), (0.,0.,5.))

Revolve
-------

Revolve face to create solid.

.. code-block:: python

    e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
    face = Face().createFace(e1)
    
    solid = Solid().revolve(face, (0.,2.,0.), (1.,2.,0.), 90.)
    
Loft
----

Loft through edges.

.. code-block:: python

    e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
    e2 = Edge().createEllipse(center=(0.,0.,5.),normal=(0.,0.,1.), rMajor = 2.0, rMinor=1.0)
    e3 = Edge().createCircle(center=(0.,0.,10.),normal=(0.,0.,1.),radius = 1.0)
    solid = Solid().loft(((e1,),(e2,),(e3,)))
    
Pipe
----

Extrude circle along arc edge

.. code-block:: python

    start = Vertex(0.,0.,0.)
    end = Vertex(2.,0.,2.)
    cen = (2.,0.,0.)
    e1 = Edge().createArc(start,end,cen)

    e2 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
    f1 = Face().createFace(e2)

    solid = Solid().pipe(f1, (e1,))

Advanced solids
---------------

Create open box with fillet edges.

.. figure:: images/box_example.jpg
    
    Box example plot.

.. code-block:: python

    solid = Solid().createBox((0.,0.,0.),(100.,100.,100.))
    solid.shell(-5, lambda near,far: near[2] > 50 and far[2] > 50)
    solid.fillet(2., lambda near,far: True)

Union of cyllinders with fillet intersection edge.

.. figure:: images/cylinder_example.jpg
    
    Cylinder example plot.
    
.. code-block:: python

    s1 = Solid().createCylinder((0.,0.,-2.),(0.,0.,2.), 1.)
    s2 = Solid().createCylinder((0.,-2.,0.),(0.,2.,0.), .9)
    solid = s1.booleanUnion(s2)

    def fillet(near, far):
        return all(abs(coord) < 1.5 for coord in (near[2], far[2], near[1], far[1]))
        
    solid.fillet(0.3, fillet)

Construc bowl like solid.

.. figure:: images/bowl_example.jpg
    
    Bowl example plot.
    
.. code-block:: python
    
    # cut sphere in half
    solid = Solid().createSphere((0.,0.,0.),10.)
    box = Solid().createBox((-11.,-11.,0.),(11.,11.,11.))
    solid.booleanDifference(box)
    
    # shell operation
    solid.shell(-2., lambda near,far: near[2] > -1 and far[2] > -1)
    
    # foot
    cone = Solid().createCone((0.,0.,-11.), (0.,0.,-7.), 5., 6.)
    solid.booleanUnion(cone)
    
    # fillet all edges
    solid.fillet(.25, lambda near, far: True)

Misc
====

Read
----

Read solid from external STEP file.

.. code-block:: python

    solid = Solid()
    solid.readSTEP('test.stp')
    solid.heal()

Write
-----

Write to external STEP file.

.. code-block:: python

    model = Model()
    model.createSphere(1.,2.,3.,.5)
    model.writeSTEP('test.stp')