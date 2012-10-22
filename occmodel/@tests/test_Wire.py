#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#
import sys
import unittest

from math import pi, sin, cos, sqrt

from occmodel import Vertex, Edge, Wire, OCCError

class test_Wire(unittest.TestCase):
    def almostEqual(self, a, b, places = 7):
        for va,vb in zip(a,b):
            self.assertAlmostEqual(va, vb, places)
    
    def test_createWire(self):
        eq = self.assertEqual
        aeq = self.assertAlmostEqual
        
        p1 = Vertex(0.,0.,0.)
        p2 = Vertex(1.,0.,0.)
        p3 = Vertex(1.,1.,0.)
        p4 = Vertex(0.,1.,0.)
        e1 = Edge().createLine(p1,p2)
        e2 = Edge().createLine(p2,p3)
        e3 = Edge().createLine(p3,p4)
        e4 = Edge().createLine(p4,p1)
        w1 = Wire().createWire((e1,e2,e3,e4))
        
        eq(len(w1), 4)            
        eq(w1.numVertices(), 4)            
        eq(w1.isNull(), False)
        eq(w1.isValid(), True)
        eq(w1.hasPlane(), True)
        aeq(w1.length(), 4.)
    
    def test_createRectangle(self):
        eq = self.assertEqual
        aeq = self.assertAlmostEqual
        
        self.assertRaises(OCCError, Wire().createRectangle, width = 1., height = 1., radius = -0.00001)
        self.assertRaises(OCCError, Wire().createRectangle, width = 1., height = 1., radius = .5000001)
        
        w1 = Wire().createRectangle(width = 1., height = 1., radius = 0.)
        aeq(w1.length(), 4.)
        
        w1 = Wire().createRectangle(width = 1., height = 1., radius = .5)
        aeq(w1.length(), pi)
    
    def test_createPolygon(self):
        eq = self.assertEqual
        aeq = self.assertAlmostEqual
        
        points = (
            (0.,0.,0.),
            (1.,0.,0.),
            (1.,1.,0.),
            (0.,1.,0.)
        )
        
        w1 = Wire().createPolygon(points, close = True)
        aeq(w1.length(), 4.)
        
        w1 = Wire().createPolygon(points, close = False)
        aeq(w1.length(), 3.)
    
    def test_offset(self):
        w1 = Wire()
        self.assertRaises(OCCError,w1.offset, 1.)
        
        w1 = Wire().createRectangle(width = 1., height = 1.)
        l = w1.length()
        w1.offset(0.1)
        self.assertEqual(w1.length() != l, True)
    
    def test_fillet(self):
        aeq = self.assertAlmostEqual
        
        w1 = Wire()
        self.assertRaises(OCCError,w1.fillet, 1.)
        
        w1 = Wire().createRectangle(width = 1., height = 1.)
        l1 = w1.length()
        w1.fillet(0.1)
        l2 = w1.length()
        self.assertEqual(l1 != l2, True)
        
        p1 = Vertex(0.,0.,0.)
        p2 = Vertex(1.,0.,0.)
        p3 = Vertex(1.,1.,0.)
        p4 = Vertex(0.,1.,0.)
        e1 = Edge().createLine(p1,p2)
        e2 = Edge().createLine(p2,p3)
        e3 = Edge().createLine(p3,p4)
        e4 = Edge().createLine(p4,p1)
        w2 = Wire().createWire((e1,e2,e3,e4))
        w2.fillet(0.1,(p1,p2,p3,p4))
        
        aeq(w1.length(),  w2.length())
    
    def test_chamfer(self):
        aeq = self.assertAlmostEqual
        
        w1 = Wire()
        self.assertRaises(OCCError,w1.chamfer, 1.)
        
        w1 = Wire().createRectangle(width = 1., height = 1.)
        l = w1.length()
        w1.chamfer(0.1)
        self.assertEqual(w1.length() != l, True)
        
        p1 = Vertex(0.,0.,0.)
        p2 = Vertex(1.,0.,0.)
        p3 = Vertex(1.,1.,0.)
        p4 = Vertex(0.,1.,0.)
        e1 = Edge().createLine(p1,p2)
        e2 = Edge().createLine(p2,p3)
        e3 = Edge().createLine(p3,p4)
        e4 = Edge().createLine(p4,p1)
        w2 = Wire().createWire((e1,e2,e3,e4))
        w2.chamfer(0.1,(p1,p2,p3,p4))
        
        aeq(w1.length(),  w2.length())
    
    def test_isClosed(self):
        eq = self.assertEqual
        
        for val in (True, False):
            w1 = Wire().createPolygon((
                (0.,0.,0.),
                (0.,0.,5.),
                (5.,0.,5.)),
                close = val
            )
            eq(w1.isClosed(), val)
    
if __name__ == "__main__":
    sys.dont_write_bytecode = True
    unittest.main()