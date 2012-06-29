#!/usr/bin/python
# -*- coding: utf-8 -*-
# This is code is commercial software.
# Copyright 2007 by Runar Tenfjord, Tenko.

import sys
import unittest

from math import pi, sin, cos, sqrt

sys.path.insert(0, '..')
from occmodel import Vector, dot, cross, isParallell, isPerpendicular
from occmodel import Transform 

class test_Vector(unittest.TestCase):
    def almostEqual(self, a, b, places = 7):
        for va,vb in zip(a,b):
            self.assertAlmostEqual(va, vb, places)
        
    def test_init_and_accessors(self):
        eq = self.almostEqual
        p = Vector(1., 2., 3.)
        eq((p.x, p.y, p.z), (1., 2., 3.))
        
        p.x, p.y, p.z = -1., -2., -3.
        eq((p.x, p.y, p.z), (-1., -2., -3.))
        
        eq(Vector(1., 2.), (1., 2., 0.))
        
        eq(Vector(), (0., 0., 0))
        
        eq(Vector((1., 2., 3.)), (1., 2., 3.))
        
        eq(Vector((1., 2.)), (1., 2., 0.))
        
        eq(Vector(()), (0., 0., 0))
        
    def test__repr__(self):
        eq = self.almostEqual
        p = Vector(eval(repr(Vector(1,2,3))))
        eq((p.x, p.y, p.z), (1., 2., 3.))

    def test__str__(self):
        assert str(Vector()).startswith(Vector().__class__.__name__)
        

    def test___getitem__(self):
        eq = self.almostEqual
        p = Vector(1., 2., 3.)
        eq((p[0], p[1], p[2]), (1., 2., 3.))
        p.x, p.y, p.z = -1., -2., -3.
        eq((p.x, p.y, p.z), (-1., -2., -3.))
        
    def test_arithmeticops(self):
        eq = self.almostEqual
        # __abs__
        eq(Vector(1., 2., 3.), abs(Vector(-1., -2., -3.)))

        # __neg__
        eq(-Vector(1., 2., 3.), Vector(-1., -2., -3.))

        # __pos__
        eq(+Vector(1., 2., -3.), Vector(1., 2., -3.))
        
        # __add__
        eq(Vector(1., 2., 3.) + Vector(-1., -2., -3.), Vector(0., 0., 0.))

        # __iadd__
        p1 = Vector(1., 2., 3.)
        p1 += Vector(-1., -2., -3.)
        eq(p1, Vector(0., 0., 0.))

        # __sub__
        self.assertTrue(Vector(1., 2., 3.) - Vector(-1., -2., -3.) == Vector(2., 4., 6.))

        # __isub__
        p1 = Vector(1., 2., 3.)
        p1 -= Vector(1., 2., 3.)
        self.assertTrue(p1 == Vector(0., 0., 0.))

        # __mul__
        eq(Vector(1., 2., 3.) * 2., Vector(2.0, 4.0, 6.0))
        eq(2. * Vector(1., 2., 3.), Vector(2.0, 4.0, 6.0))
        
        p = Vector(1.,2.,3.)
        m = Transform().translate(3.,2.,1.)
        q = p * m
        eq(q, Vector(4.,4.,4.))
        
        self.assertAlmostEqual(Vector(1., 2., 3.) *  Vector(4,5,6),
                               1. * 4. + 2. * 5. + 3. * 6. )
        
        # __rmul__           
        eq(2. * Vector(1., 2., 3.), Vector(2.0, 4.0, 6.0))
       
        # __imul__
        p1 = Vector(1.,2.,3.)
        p1 *= 2.
        eq(p1, Vector(2., 4., 6.))

        # __div__
        eq(Vector(1., 2., 3.) / 2., Vector(1./2., 2./2., 3./2.))

        # __idiv__
        p1 = Vector(1., 2., 3.)
        p1 /= 2.
        eq(p1, Vector(1./2., 2./2., 3./2.))

        # __rdiv__
        eq(1. / Vector(1., 2., 3.), Vector(1./1., 1./2., 1./3.))
    
    def test_set(self):
        eq = self.almostEqual
        p = Vector(1., 2., 3.)
        p.set(4., 5., 6.)
        eq(p, (4., 5., 6.))
        
        p = Vector(1., 2., 3.)
        p.set(4., 5.)
        eq(p, (4., 5., 3.))
        
        p = Vector(1., 2., 3.)
        p.set(4.)
        eq(p, (4., 2., 3.))
        
        p = Vector(1., 2., 3.)
        p.set()
        eq(p, (1., 2., 3.))
        
        p = Vector(1., 2., 3.)
        p.set((4., 5., 6.))
        eq(p, (4., 5., 6.))
        
        p = Vector(1., 2., 3.)
        p.set((4., 5.))
        eq(p, (4., 5., 3.))
        
        p = Vector(1., 2., 3.)
        p.set((4.,))
        eq(p, (4., 2., 3.))
        
        p = Vector(1., 2., 3.)
        p.set(())
        eq(p, (1., 2., 3.))
        
    def test_isZero(self):
        self.assertTrue(Vector(0., 0., 0.).isZero())
        self.assertTrue(not Vector(1., 2., 3.).isZero())

    def test_maximumCoordinateIndex(self):
        self.assertTrue(Vector(0., 4., 2.).maximumCoordinateIndex() == 1)

    def test_maximumCoordinate(self):
        eq = self.assertAlmostEqual
        eq(Vector(0., 4., 2.).maximumCoordinate(), 4.)
    
    def test_length(self):
        eq = self.assertAlmostEqual
        eq(Vector(1.,2.,3.).length, sqrt(1.**2 + 2.**2 + 3.**2))
    
    def test_lengthSquared(self):
        eq = self.assertAlmostEqual
        eq(Vector(1.,2.,3.).lengthSquared, 1.**2 + 2.**2 + 3.**2)
    
    def test_unit(self):
        eq = self.assertAlmostEqual
        p = Vector(1., 2., 3.).unit()
        eq(p.x**2 + p.y**2 + p.z**2, 1.)
    
    def test_dot(self):
        eq = self.assertAlmostEqual
        eq(dot(Vector(1., 2., 3.), Vector(4,5,6)), 1. * 4. + 2. * 5. + 3. * 6. )
    
    def test_cross(self):
        eq = self.almostEqual
        eq(cross(Vector(1., 2., 3.), Vector(4., 5., 6.)), (2. * 6. - 5. * 3., 3. * 4. - 6. * 1., 1. * 5. - 4. * 2.))
    
    def test_isParallell(self):
        self.assertTrue(isParallell(Vector(1., 2., 3.), Vector(1., 2., 3.)) == True)
        self.assertTrue(isParallell(Vector(2., 2., 1.), Vector(1., 2., 3.)) == False)
    
    def test_isPerpendicular(self):
        self.assertTrue(isPerpendicular(Vector(1., 0., 0.), Vector(0., 1., 0.)) == True)
        self.assertTrue(isPerpendicular(Vector(0., 1., 0.), Vector(0., 0., 1.)) == True)
        self.assertTrue(isPerpendicular(Vector(1., 2., 3.), Vector(1., 2., 3.)) == False)

if __name__ == "__main__":
    sys.dont_write_bytecode = True
    unittest.main()