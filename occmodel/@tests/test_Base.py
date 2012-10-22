#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#
import sys
import unittest

from math import pi, sin, cos, sqrt

from geotools import Point, Vector, Plane, Transform
from occmodel import Edge, Vertex, OCCError

class test_Base(unittest.TestCase):
    def almostEqual(self, a, b, places = 7):
        for va,vb in zip(a,b):
            self.assertAlmostEqual(va, vb, places)
            
    def test_empty(self):
        eq = self.assertEqual
        
        e1 = Edge()
        
        self.assertRaises(OCCError, e1.shapeType)
        eq(e1.isNull(), True)
        eq(e1.isValid(), False)
        eq(e1.isDegenerated(), True)
        eq(e1.hasPlane(), False)
        eq(len(e1), 0)
        eq(tuple(e1), ())
        
        m = Transform().translate(1.,2.,3.)
        self.assertRaises(OCCError, e1.transform, m)
        self.assertRaises(OCCError, e1.translate, (1.,2.,3.))
        self.assertRaises(OCCError, e1.rotate, pi, (0.,1.,0.))
        self.assertRaises(OCCError, e1.scale, (0.,0.,0.), 2.)
        
    def test_base(self):
        eq = self.assertEqual
        
        start, end = Vertex(1.,0.,0.), Vertex(-1.,0.,0.)
        e1 = Edge().createLine(start, end)
        
        eq(e1.shapeType() is Edge, True)
        
        eq(e1.isNull(), False)
        eq(e1.isValid(), True)
        eq(e1.isDegenerated(), False)
        eq(e1.hasPlane(), False)
        
        e2 = e1.copy()
        eq(e2.isNull(), False)
        eq(e2.isValid(), True)
        eq(e2.isDegenerated(), False)
        eq(e2.hasPlane(), False)
        
        # test hallow copy equallity
        eq(e2.isEqual(e1), True)
        eq(e2 == e1, True)
        eq(e2 != e1, False)
        eq(e1.hashCode() == e2.hashCode(), True)
        
        # test copy of underlying geometry
        e3 = e1.copy(deepCopy = True)
        eq(e3.isEqual(e1), False)
        eq(e1.hashCode() == e3.hashCode(), False)
        
        # test serialize
        e4 = Edge().fromString(e1.toString())
        eq(e4.isEqual(e1), False)
        eq(e1.hashCode() == e4.hashCode(), False)
        
        eq(len(e1), 2)
        
        vertices = set((start.hashCode(), end.hashCode()))
        for vertex in e1:
            hid = vertex.hashCode()
            if hid in vertices:
                vertices.remove(hid)
        
        eq(len(vertices), 0)
    
    def test_hasPlane(self):
        eq = self.assertEqual
        aeq = self.almostEqual
        
        e5 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
        eq(e5.hasPlane(), True)
        
        pnt = Point(-1.,-1.,-1.)
        vec = Vector(-1.,-1.,-1.)
        e5.hasPlane(pnt, vec)
        aeq(pnt, (0.,0.,0.))
        aeq(vec, (0.,0.,1.))
    
    def test_bbox(self):
        eq = self.assertEqual
        aeq = self.almostEqual
        
        e1 = Edge().createLine((1.,-2.,3.), (-1.,2.,-3.))
        bbox = e1.boundingBox()
        
        eq(bbox.isValid(), True)
        aeq(bbox.min, (-1.,-2.,-3.))        
        aeq(bbox.max, (1.,2.,3.))
    
    def test_transform(self):
        eq = self.almostEqual
         
        e1 = Edge().createLine((-1.,-2.,-3.), (0.,0.,0.))
        m = Transform().translate(1.,2.,3.)
        e1.transform(m)
        
        v1, v2 = e1
        eq(v1, (0.,0.,0.))        
        eq(v2, (1.,2.,3.))
        
        m = Transform().translate(-1.,-2.,-3.)
        e2 = e1.transform(m, copy = True)
        
        v1, v2 = e1
        eq(v1, (0.,0.,0.))
        eq(v2, (1.,2.,3.))
        
        v1, v2 = e2
        eq(v1, (-1.,-2.,-3.))        
        eq(v2, (0.,0.,0.))
        
    def test_rotate(self):
        eq = self.almostEqual
         
        e1 = Edge().createLine((0.,0.,0.), (1.,0.,0.))
        e1.rotate(-.5*pi, (0.,1.,0.))
        
        v1, v2 = e1
        eq(v1, (0.,0.,0.))
        eq(v2, (0.,0.,1.))
        
        e1.rotate(.5*pi, (0.,1.,0.))
        
        v1, v2 = e1
        eq(v1, (0.,0.,0.))
        eq(v2, (1.,0.,0.))
        
        e2 = e1.rotate(-.5*pi, (0.,1.,0.), copy = True)
        
        v1, v2 = e1
        eq(v1, (0.,0.,0.))
        eq(v2, (1.,0.,0.))
        
        v1, v2 = e2
        eq(v1, (0.,0.,0.))
        eq(v2, (0.,0.,1.))
        
        e1 = Edge().createLine((0.,0.,0.), (1.,0.,0.))
        e1.rotate(-.5*pi, (0.,1.,0.), (.5,0.,0.))
        v1, v2 = e1
        
        eq(v1, (.5,0.,-.5))
        eq(v2, (.5,0.,.5))
        
    def test_translate(self):
        eq = self.almostEqual
        
        e1 = Edge().createLine((-1.,-2.,-3.), (0.,0.,0.))
        e1.translate((1.,2.,3.))
        
        v1, v2 = e1
        eq(v1, (0.,0.,0.))
        eq(v2, (1.,2.,3.))
        
        e2 = e1.translate((-1.,-2.,-3.), copy = True)
        
        v1, v2 = e1
        eq(v1, (0.,0.,0.))
        eq(v2, (1.,2.,3.))
        
        v1, v2 = e2
        eq(v1, (-1.,-2.,-3.))
        eq(v2, (0.,0.,0.))
        
    def test_scale(self):
        eq = self.almostEqual
        
        e1 = Edge().createLine((0.,0.,0.), (1.,0.,1.))
        e1.scale((0.,0.,0.), .5)
        v1, v2 = e1
        
        eq(v1, (0.,0.,0.))
        eq(v2, (.5,0.,.5))

        e2 = e1.scale((0.,0.,0.), 2., copy = True)
        
        v1, v2 = e1
        eq(v1, (0.,0.,0.))
        eq(v2, (.5,0.,.5))
        
        v1, v2 = e2
        
        eq(v1, (0.,0.,0.))
        eq(v2, (1.,0.,1.))

    def test_mirror(self):
        eq = self.almostEqual
        
        e1 = Edge().createLine((0.,0.,0.), (1.,0.,0.))
        plane = Plane.fromNormal((0.,0.,0.), (1.,0.,0.))
        e1.mirror(plane)
        v1, v2 = e1
        
        eq(v1, (0.,0.,0.))
        eq(v2, (-1.,0.,0.))
        
        e2 = e1.mirror(plane, copy = True)
        v1, v2 = e1
        eq(v1, (0.,0.,0.))
        eq(v2, (-1.,0.,0.))
        
        v1, v2 = e2
        eq(v1, (0.,0.,0.))
        eq(v2, (1.,0.,0.))
        
if __name__ == "__main__":
    sys.dont_write_bytecode = True
    unittest.main()