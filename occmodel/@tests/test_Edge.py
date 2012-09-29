#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import unittest

from math import pi, sin, cos, sqrt

sys.path.insert(0, '..')
from occmodel import Vertex, Edge

class test_Edge(unittest.TestCase):
    
    def test_createLine(self):
        eq = self.assertAlmostEqual
        
        start = Vertex(1.,0.,0.)
        end = Vertex(-1.,0.,0.)
        e1 = Edge().createLine(end,start)
        
        eq(e1.length(), 2.)
    
    def test_createArc(self):
        eq = self.assertAlmostEqual
        
        start = Vertex(0.,0.,0.)
        end = Vertex(1.,0.,1.)
        cen = (1.,0.,0.)
        e1 = Edge().createArc(start,end,cen)
        
        eq(e1.length(), .5*pi)
    
    def test_createArc3P(self):
        eq = self.assertAlmostEqual
        
        start = Vertex(1.,0.,0.)
        end = Vertex(-1.,0.,0.)
        pnt = (0.,1.,0.)
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
        eq = self.assertAlmostEqual
        
        start = Vertex(0.,0.,0.)
        end = Vertex(1.,0.,0.)
        pnts = ((0.,2.,0.), (1.,1.5,0.))
        e1 = Edge().createBezier(start,end,pnts)
    
    def test_createSpline(self):
        eq = self.assertAlmostEqual
        
        start = Vertex(0.,0.,0.)
        end = Vertex(1.,0.,0.)
        pnts = ((0.,2.,0.), (5.,1.5,0.))
        e1 = Edge().createSpline(start,end,pnts)
        
if __name__ == "__main__":
    sys.dont_write_bytecode = True
    unittest.main()