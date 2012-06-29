These examples are available by executing the demo
function.

.. code-block:: python

    from occmodel import demo
    demo()

To view the results simply pass a sequece of object or a single
object to the viewer function.

.. code-block:: python

    from occmodel import viewer
    viewer(solid)
    viewer((solid,face,edge))
    
Arc
---

.. code-block:: python

    start = Vertex(1.,0.,0.)
    end = Vertex(-1.,0.,0.)
    pnt = (0.,1.,0.)
    edge = Edge().createArc3P(start,end,pnt)

Face
----

Create face from circle edge and interior point

.. code-block:: python

    e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
    face = Face().createFace(e1, ((0.,.5,.25),))

Box
---

Create box with fillet edges

.. code-block:: python

    solid = Solid().createBox((0.,0.,0.),(100.,100.,100.))
    solid.shell(-5, lambda near,far: near[2] > 50 and far[2] > 50)
    solid.fillet(2., lambda near,far: True)

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

Loft
----

Loft through edges

.. code-block:: python

    e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
    e2 = Edge().createEllipse(center=(0.,0.,5.),normal=(0.,0.,1.), rMajor = 2.0, rMinor=1.0)
    e3 = Edge().createCircle(center=(0.,0.,10.),normal=(0.,0.,1.),radius = 1.0)
    solid = Solid().loft(((e1,),(e2,),(e3,)))

Boolean
-------

Boolean between two solid spheres

.. code-block:: python

    s1 = Solid().createSphere((0.,0.,0.),.5)
    s2 = Solid().createSphere((.25,0.,0.),.5)
    solid = s1.booleanUnion(s2)