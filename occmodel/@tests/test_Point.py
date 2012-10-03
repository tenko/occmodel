#!/usr/bin/python
# -*- coding: utf-8 -*-
# This is code is commercial software.
# Copyright 2007 by Runar Tenfjord, Tenko.

import sys
import unittest

from math import pi, sin, cos, sqrt

from occmodel import Point, distance, Polar
from occmodel import Transform      
       
class test_Point(unittest.TestCase):
    def almostEqual(self, a, b, places = 7):
        for va,vb in zip(a,b):
            self.assertAlmostEqual(va, vb, places)
        
    def test_init_and_accessors(self):
        eq = self.almostEqual
        p = Point(1., 2., 3.)
        eq((p.x, p.y, p.z), (1., 2., 3.))
        
        p.x, p.y, p.z = -1., -2., -3.
        eq((p.x, p.y, p.z), (-1., -2., -3.))
        
        eq(Point(1., 2.), (1., 2., 0.))
        
        eq(Point(), (0., 0., 0))
        
        eq(Point((1., 2., 3.)), (1., 2., 3.))
        
        eq(Point((1., 2.)), (1., 2., 0.))
        
        eq(Point(()), (0., 0., 0))
        
    def test__repr__(self):
        eq = self.almostEqual
        p = Point(eval(repr(Point(1,2,3))))
        eq((p.x, p.y, p.z), (1., 2., 3.))

    def test__str__(self):
        assert str(Point()).startswith(Point().__class__.__name__)

    def test___getitem__(self):
        eq = self.almostEqual
        p = Point(1., 2., 3.)
        eq((p[0], p[1], p[2]), (1., 2., 3.))
        p.x, p.y, p.z = -1., -2., -3.
        eq((p.x, p.y, p.z), (-1., -2., -3.))
    
    def test__richcmp__(self):
        EPS = 2*2.2204460492503132e-16
        
        # ==
        self.assertTrue(not Point(1., 2., 3.) == False)
        self.assertTrue(Point(1., 2., 3.) == Point(1., 2., 3.))
        self.assertTrue(not Point(1.1, 2.1, 3.1) == Point(1., 2., 3.))
        self.assertTrue(Point(1. + EPS/2., 2. + EPS/2., 3. + EPS/2.) == Point(1., 2., 3.))
        self.assertTrue(not Point(1. + 2.*EPS, 2. + 2.*EPS, 3. + 2.*EPS) == Point(1., 2., 3.))
        
        #!=
        self.assertTrue(Point(1., 2., 3.) != True)
        self.assertTrue(Point(1., 2., 3.) != Point(3., 2., 1.))
        self.assertTrue(not Point(1., 2., 3.) != Point(1., 2., 3.))
        self.assertTrue(not Point(1. + EPS/2., 2. + EPS/2., 3. + EPS/2.) != Point(1., 2., 3.))
        self.assertTrue(Point(1. + 2.*EPS, 2. + 2.*EPS, 3. + 2.*EPS) != Point(1., 2., 3.))
        
        #<
        self.assertTrue(Point(.9, 1.9, 2.9) < Point(1., 2., 3.))
        self.assertTrue(not Point(1.1, 2.1, 3.1) < Point(1., 2., 3.))
        
        #<=
        self.assertTrue(Point(1., 2., 3.) <= Point(1., 2., 3.))
        self.assertTrue(not Point(1.1, 2.1, 3.1) <= Point(1., 2., 3.))
        self.assertTrue(Point(1. + EPS/2., 2. + EPS/2., 3. + EPS/2.) <= Point(1., 2., 3.))
        self.assertTrue(not Point(1. + 2.*EPS, 2. + 2.*EPS, 3. + 2.*EPS) <= Point(1., 2., 3.))
        
        #>
        self.assertTrue(Point(1., 2., 3.) > Point(.9, 1.9, 2.9))
        self.assertTrue(not Point(1., 2., 3.) > Point(1.1, 2.1, 3.1))
        
        #>=
        self.assertTrue(Point(1., 2., 3.) >= Point(1., 2., 3.))
        self.assertTrue(not Point(1., 2., 3.) >= Point(1.1, 2.1, 3.1))
        self.assertTrue(Point(1. + EPS/2., 2. + EPS/2., 3. + EPS/2.) >= Point(1., 2., 3.))
        self.assertTrue(not Point(1. - 2.*EPS, 2. - 2.*EPS, 3. - 2.*EPS) >= Point(1., 2., 3.))
        
    def test_arithmeticops(self):
        eq = self.almostEqual
        # __abs__
        eq(Point(1., 2., 3.), abs(Point(-1., -2., -3.)))

        # __neg__
        eq(-Point(1., 2., 3.), Point(-1., -2., -3.))

        # __pos__
        eq(+Point(1., 2., -3.), Point(1., 2., -3.))
        
        # __add__
        eq(Point(1., 2., 3.) + Point(-1., -2., -3.), Point(0., 0., 0.))

        # __iadd__
        p1 = Point(1., 2., 3.)
        p1 += Point(-1., -2., -3.)
        eq(p1, Point(0., 0., 0.))

        # __sub__
        self.assertTrue(Point(1., 2., 3.) - Point(-1., -2., -3.) == Point(2., 4., 6.))

        # __isub__
        p1 = Point(1., 2., 3.)
        p1 -= Point(1., 2., 3.)
        self.assertTrue(p1 == Point(0., 0., 0.))

        # __mul__
        eq(Point(1., 2., 3.) * 2., Point(2.0, 4.0, 6.0))
        eq(2. * Point(1., 2., 3.), Point(2.0, 4.0, 6.0))
         
        p = Point(1.,2.,3.)
        m = Transform().translate(3.,2.,1.)
        q = p * m
        eq(q, Point(4.,4.,4.))
        
        # __rmul__           
        eq(2. * Point(1., 2., 3.), Point(2.0, 4.0, 6.0))
       
        # __imul__
        p1 = Point(1.,2.,3.)
        p1 *= 2.
        eq(p1, Point(2., 4., 6.))

        # __div__
        eq(Point(1., 2., 3.) / 2., Point(1./2., 2./2., 3./2.))

        # __idiv__
        p1 = Point(1., 2., 3.)
        p1 /= 2.
        eq(p1, Point(1./2., 2./2., 3./2.))

        # __rdiv__
        eq(1. / Point(1., 2., 3.), Point(1./1., 1./2., 1./3.))
    
    def test_set(self):
        eq = self.almostEqual
        p = Point(1., 2., 3.)
        p.set(4., 5., 6.)
        eq(p, (4., 5., 6.))
        
        p = Point(1., 2., 3.)
        p.set(4., 5.)
        eq(p, (4., 5., 3.))
        
        p = Point(1., 2., 3.)
        p.set(4.)
        eq(p, (4., 2., 3.))
        
        p = Point(1., 2., 3.)
        p.set()
        eq(p, (1., 2., 3.))
        
        p = Point(1., 2., 3.)
        p.set((4., 5., 6.))
        eq(p, (4., 5., 6.))
        
        p = Point(1., 2., 3.)
        p.set((4., 5.))
        eq(p, (4., 5., 3.))
        
        p = Point(1., 2., 3.)
        p.set((4.,))
        eq(p, (4., 2., 3.))
        
        p = Point(1., 2., 3.)
        p.set(())
        eq(p, (1., 2., 3.))
        
    def test_isZero(self):
        self.assertTrue(Point(0., 0., 0.).isZero())
        self.assertTrue(not Point(1., 2., 3.).isZero())

    def test_maximumCoordinateIndex(self):
        self.assertTrue(Point(0., 4., 2.).maximumCoordinateIndex() == 1)

    def test_maximumCoordinate(self):
        eq = self.assertEqual
        eq(Point(0., 4., 2.).maximumCoordinate(), 4.)

    def test_distanceTo(self):
        eq = self.assertAlmostEqual
        eq(Point(1.,1.,1.).distanceTo(Point(2.,3.,4.)), sqrt(14))
                      
    def test_distance(self):
        eq = self.assertAlmostEqual
        eq(distance(Point(1.,1.,1.), Point(2.,3.,4.)), sqrt(14))
        
    def test_Polar(self):
        eq = self.almostEqual
        # Multiple args
        p = Polar(2.,pi/2., pi/4.)
        eq(p, (2.*cos(pi/4.)*cos(pi/2.), 2.*cos(pi/4.)*sin(pi/2.),2.*sin(pi/4.)))
        
        # Sequence
        p = Polar((2.,pi/2., pi/4.))
        eq(p, (2.*cos(pi/4.)*cos(pi/2.), 2.*cos(pi/4.)*sin(pi/2.),2.*sin(pi/4.)))

if __name__ == "__main__":
    sys.dont_write_bytecode = True
    unittest.main()