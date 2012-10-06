#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import unittest

from math import pi, sin, cos, sqrt

from occmodel import Vertex, Edge

class test_Edge(unittest.TestCase):
    def almostEqual(self, a, b, places = 7):
        for va,vb in zip(a,b):
            self.assertAlmostEqual(va, vb, places)
            
    def test_createLine(self):
        eq = self.assertEqual
        aeq = self.assertAlmostEqual
        
        args = \
        (
            (Vertex(1.,0.,0.), Vertex(-1.,0.,0.)),
            ((1.,0.,0.), (-1.,0.,0.)),
            ((0.,1.,0.), (0.,-1.,0.)),
            ((0.,0.,1.), (0.,0.,-1.)),
        )
        for start, end in args:
            e1 = Edge().createLine(start, end)
            
            eq(len(e1), 2)
            
            eq(e1.isNull(), False)
            eq(e1.isValid(), True)
            eq(e1.isDegenerated(), False)
            eq(e1.hasPlane(), False)
            
            aeq(e1.length(), 2)
    
    def test_createArc(self):
        eq = self.assertAlmostEqual
        
        args = \
        (
            (Vertex(0.,0.,0.), Vertex(1.,0.,1.), (1.,0.,0.)),
            ((0.,0.,0.), (1.,0.,1.), (1.,0.,0.)),
            ((0.,1.,0.), (1.,1.,1.), (1.,1.,0.)),
        )
        for start, end, cen in args:
            e1 = Edge().createArc(start,end,cen)
            
            eq(e1.length(), .5*pi)
    
    def test_createArc3P(self):
        eq = self.assertAlmostEqual
        
        args = \
        (
            (Vertex(1.,0.,0.), Vertex(-1.,0.,0.), (0.,1.,0.)),
            ((1.,0.,0.), (-1.,0.,0.), (0.,1.,0.)),
            ((1.,1.,0.), (-1.,1.,0.), (0.,2.,0.)),
        )
        for start, end, pnt in args:
            e1 = Edge().createArc3P(start,end,pnt)
            eq(e1.length(), pi)
    
    def test_createCircle(self):
        eq = self.assertAlmostEqual
        
        e1 = Edge()
        center = (0.,0.,0.)
        normal = (0.,0.,1.)
        radius = 1.
        
        e1.createCircle(center, normal, radius)
        
        eq(e1.length(), 2*pi)
    
    def test_createBezier(self):
        eq = self.almostEqual
        
        start = Vertex(0.,0.,0.)
        end = Vertex(1.,0.,0.)
        pnts = ((0.,2.,0.), (1.,1.5,0.))
        e1 = Edge().createBezier(start,end,pnts)
        
        v1, v2 = e1
        eq(v1, start)
        eq(v2, end)
        
        pnts = ((0.,0.,0.),(0.,2.,0.), (1.,1.5,0.),(1.,0.,0.))
        e2 = Edge().createBezier(points = pnts)
        
        v1, v2 = e2
        eq(v1, start)
        eq(v2, end)
        
        self.assertAlmostEqual(e1.length(), e2.length())
    
    def test_createSpline(self):
        eq = self.almostEqual
        
        start = Vertex(0.,0.,0.)
        end = Vertex(1.,0.,0.)
        pnts = ((0.,2.,0.), (5.,1.5,0.))
        e1 = Edge().createSpline(start,end,pnts)
        
        v1, v2 = e1
        eq(v1, start)
        eq(v2, end)
        
if __name__ == "__main__":
    sys.dont_write_bytecode = True
    unittest.main()