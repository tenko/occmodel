#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#
import sys
import unittest

from math import pi, sin, cos, sqrt

from occmodel import Vertex, Edge, Wire, Face, OCCError

class test_Face(unittest.TestCase):
    
    def test_createFace(self):
        eq = self.assertAlmostEqual
        
        self.assertRaises(OCCError, Face().createFace, Wire())
        
        # square face
        p1 = Vertex(0.,0.,0.)
        p2 = Vertex(1.,0.,0.)
        p3 = Vertex(1.,1.,0.)
        p4 = Vertex(0.,1.,0.)
        e1 = Edge().createLine(p1,p2)
        e2 = Edge().createLine(p2,p3)
        e3 = Edge().createLine(p3,p4)
        e4 = Edge().createLine(p4,p1)
        
        w1 = Wire().createWire((e1,e1,e1,e1))
        self.assertRaises(OCCError, Face().createFace, w1)
        
        w2 = Wire().createWire((e1,e2,e3,e4))
        
        face = Face().createFace(w2)
        
        self.assertEqual(face.numWires(), 1)
        self.assertEqual(face.numFaces(), 1)
        eq(face.area(), 1.)
        
        # circular face
        e1 = Edge()
        center = (0.,0.,0.)
        normal = (0.,0.,1.)
        radius = 1.
        
        e1.createCircle(center, normal, radius)
        face = Face().createFace(e1)
        eq(face.area(), pi, places = 4)
        
    def test_createPolygonal(self):
        eq = self.assertAlmostEqual
        
        pnts = ((0.,0.,0.), (1.,0.,0.), (1.,1.,0.), (0.,1.,0.))
        face = Face().createPolygonal(pnts)
        eq(face.area(), 1.)
    
    def test_extrude(self):
        eq = self.assertAlmostEqual
        
        # square face
        p1 = Vertex(0.,0.,0.)
        p2 = Vertex(1.,0.,0.)
        e1 = Edge().createLine(p1,p2)

        face = Face().extrude(e1, (0.,0.,0.),(0.,1.,0.))
        eq(face.area(), 1.)
    
    def test_revolve(self):
        eq = self.assertAlmostEqual
        
        # square face
        p1 = Vertex(0.,0.,0.)
        p2 = Vertex(1.,0.,0.)
        e1 = Edge().createLine(p1,p2)

        face = Face().revolve(e1, (0.,1.,0.),(1.,1.,0.), pi)
        
        eq(face.area(), pi)
        
if __name__ == "__main__":
    sys.dont_write_bytecode = True
    unittest.main()