#!/usr/bin/python
# -*- coding: utf-8 -*-
# This is code is commercial software.
# Copyright 2007 by Runar Tenfjord, Tenko.
import sys
import unittest

from math import pi, sqrt

sys.path.insert(0, '..')
from occmodel import Point, Vector, Plane, Transform

class test_Plane(unittest.TestCase):  
    def test_init(self):
        p1 = Plane((0.,0.,0.), (-1.,0.,0.), (0.,-1.,0.))
        
        self.assertTrue(p1.origin == Point(0.,0.,0.))
        self.assertTrue(p1.xaxis == Vector(-1.,0.,0.))
        self.assertTrue(p1.yaxis == Vector(0.,-1.,0.))
        self.assertTrue(p1.zaxis == Vector(0.,0.,1.))
        
        self.assertTrue(p1.a == 0.)
        self.assertTrue(p1.b == 0.)
        self.assertTrue(p1.c == 1.)
        self.assertTrue(p1.d == 0.)
        
    def test_fromNormal(self):
        p1 = Plane.fromNormal((0.,0.,0.), (0.,0.,1.))
        
        self.assertTrue(p1.origin == Point(0.,0.,0.))
        self.assertTrue(p1.xaxis == Vector(-1.,0.,0.))
        self.assertTrue(p1.yaxis == Vector(0.,-1.,0.))
        self.assertTrue(p1.zaxis == Vector(0.,0.,1.))
        
        self.assertTrue(p1.a == 0.)
        self.assertTrue(p1.b == 0.)
        self.assertTrue(p1.c == 1.)
        self.assertTrue(p1.d == 0.)

    def test_fromFrame(self):
        p1 = Plane.fromFrame((0.,0.,0.), (-1.,0.,0.), (0.,-1.,0.))
        
        self.assertTrue(p1.origin == Point(0.,0.,0.))
        self.assertTrue(p1.xaxis == Vector(-1.,0.,0.))
        self.assertTrue(p1.yaxis == Vector(0.,-1.,0.))
        self.assertTrue(p1.zaxis == Vector(0.,0.,1.))
        
        self.assertTrue(p1.a == 0.)
        self.assertTrue(p1.b == 0.)
        self.assertTrue(p1.c == 1.)
        self.assertTrue(p1.d == 0.)
    
    def test_distanceTo(self):
        p1 = Plane((0.,0.,0.), (-1.,0.,0.), (0.,-1.,0.))
        
        self.assertTrue(p1.distanceTo((0.,0.,-1.5)) == -1.5)
        self.assertTrue(p1.distanceTo((0.,0.,1.5)) == 1.5)

    def test_closestPoint(self):
        p1 = Plane((0.,0.,0.), (-1.,0.,0.), (0.,-1.,0.))
        
        self.assertTrue(p1.closestPoint((1.,2.,-1.5)) == Point(1.,2.,0.))
        
    def test_flip(self):
        p1 = Plane((0.,0.,0.), (-1.,0.,0.), (0.,-1.,0.))
        
        self.assertTrue(p1.distanceTo((0.,0.,-1.5)) == -1.5)
        self.assertTrue(p1.distanceTo((0.,0.,1.5)) == 1.5)
        
        p1.flip()
        
        self.assertTrue(p1.distanceTo((0.,0.,-1.5)) == 1.5)
        self.assertTrue(p1.distanceTo((0.,0.,1.5)) == -1.5)
    
    def test_transform(self):
        p = Plane.fromNormal((0.,0.,0.), (0.,0.,1.))
        tr = Transform().translate(0.,0.,1.)
        
        self.assertTrue(p.distanceTo((0.,0.,-1.5)) == -1.5)
        self.assertTrue(p.origin == Point(0.,0.,0.))
        
        p.transform(tr)
        
        self.assertTrue(p.distanceTo((0.,0.,-1.5)) == -2.5)
        self.assertTrue(p.origin == Point(0.,0.,1.))
    
    def test_intersectLine(self):
        p = Plane((0.,0.,0.), (-1.,0.,0.), (0.,-1.,0.))
        
        a = (0.,0.,-1.)
        b = (0.,0.,1.)
        
        self.assertTrue(p.intersectLine(a, b) == (0.,0.,0.))
        
        a = (1.,1.,-1.)
        b = (1.,1.,1.)
        
        self.assertTrue(p.intersectLine(a, b) == (1.,1.,0.))

if __name__ == "__main__":
    sys.dont_write_bytecode = True
    unittest.main()