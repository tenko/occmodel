#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#
import sys
import unittest

from math import pi, sin, cos, sqrt

from occmodel import Vertex, Edge, OCCError

class test_Edge(unittest.TestCase):
    def almostEqual(self, a, b, places = 7):
        for va,vb in zip(a,b):
            self.assertAlmostEqual(va, vb, places)
        
    def test_length(self):
        
        e1 =  Edge()
        # bug in Cython?
        #self.assertRaises(OCCError, e1.length)
        
        e1 = Edge().createLine((0.,0.,0.), (1.,0.,0.))
        self.assertAlmostEqual(e1.length(), 1.)
        
    def test_createLine(self):
        eq = self.assertEqual
        aeq = self.assertAlmostEqual
        
        self.assertRaises(OCCError, Edge().createLine, (0.,0.,0.), (0.,0.,0.))
        
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
        
        v1 = (0.,0.,0.)
        self.assertRaises(OCCError, Edge().createArc, v1, v1, v1)
        
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
        
        v1 = (0.,0.,0.)
        self.assertRaises(OCCError, Edge().createArc3P, v1, v1, v1)
        
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
        
        self.assertRaises(OCCError, Edge().createCircle, (0.,0.,0.), (0.,0.,1.), -1.)
        self.assertRaises(OCCError, Edge().createCircle, (0.,0.,0.), (0.,0.,1.), 0.)
        
        e1 = Edge()
        center = (0.,0.,0.)
        normal = (0.,0.,1.)
        radius = 1.
        
        e1.createCircle(center, normal, radius)
        
        eq(e1.length(), 2*pi)
    
    def test_createEllipse(self):
        eq = self.assertAlmostEqual
        
        self.assertRaises(OCCError, Edge().createEllipse, (0.,0.,0.), (0.,0.,1.), 0., 0.)
        
        e1 = Edge().createEllipse(center=(0.,0.,0.),normal=(0.,0.,1.), rMajor = 1., rMinor=.5)
        eq(e1.length(), .5*sqrt(93. + .5*sqrt(3.)), 1)
    
    def test_createHelix(self):
        eq = self.assertAlmostEqual
        
        self.assertRaises(OCCError, Edge().createHelix, pitch = .5, height = 0., radius = 0., angle = pi/5.)
        self.assertRaises(OCCError, Edge().createHelix, pitch = .5, height = 0., radius = .25, angle = pi/5.)
        
        e1 = Edge().createHelix(pitch = .5, height = 1., radius = .25, angle = pi/5.)
        self.assertEqual(e1.length() > 1., True)
        
    def test_createBezier(self):
        eq = self.almostEqual
        
        pnts = ((0.,0.,0.),(0.,0.,0.), (0.,0.,0.),(0.,0.,0.))
        self.assertRaises(OCCError, Edge().createBezier, points = pnts)
        
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
        
        pnts = ((0.,0.,0.),(0.,0.,0.), (0.,0.,0.),(0.,0.,0.))
        self.assertRaises(OCCError, Edge().createSpline, points = pnts)
        
        start = Vertex(0.,0.,0.)
        end = Vertex(1.,0.,0.)
        pnts = ((0.,2.,0.), (5.,1.5,0.))
        e1 = Edge().createSpline(start,end,pnts)
        
        v1, v2 = e1
        eq(v1, start)
        eq(v2, end)
        
        pnts = ((0.,0.,0.),(0.,2.,0.), (5.,1.5,0.),(1.,0.,0.))
        e2 = Edge().createSpline(points = pnts)
        self.assertAlmostEqual(e1.length(), e2.length())
    
    def test_isClosed(self):
        eq = self.assertEqual
        
        e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = 1.)
        eq(e1.isClosed(), True)
        
        e1 = Edge().createArc((0.,0.,0.),(1.,0.,1.),(1.,0.,0.))
        eq(e1.isClosed(), False)

if __name__ == "__main__":
    sys.dont_write_bytecode = True
    unittest.main()