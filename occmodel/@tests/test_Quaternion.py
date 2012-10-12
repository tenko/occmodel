#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#
import sys
import unittest

import math

from occmodel import Quaternion, Vector

class test_Quaternion(unittest.TestCase):
    def test_init_and_accessors(self):
        q = Quaternion()
        self.assertTrue(q.w == 1.0)
        self.assertTrue(q.x == 0.)
        self.assertTrue(q.y == 0.)
        self.assertTrue(q.z == 0.)
        
        q = Quaternion(1.,2.,3.,4.)
        self.assertTrue(q.w == 1.)
        self.assertTrue(q.x == 2.)
        self.assertTrue(q.y == 3.)
        self.assertTrue(q.z == 4.)
        
        q = Quaternion()
        q.w = 5.
        q.x = 2.
        q.y = 3.
        q.z = 4.
        
        self.assertTrue(q.w == 5.)
        self.assertTrue(q.x == 2.)
        self.assertTrue(q.y == 3.)
        self.assertTrue(q.z == 4.)
    
    def test_length(self):
        eq = self.assertAlmostEqual
        
        q = Quaternion()
        self.assertTrue(q.length == 1.0)
        
        q = Quaternion(1.,2.,3.,4.)
        self.assertTrue(q.length != 1.0)
        
        q.unit()
        eq(q.length, 1.)
    
    def test_lengthSquared(self):
        eq = self.assertAlmostEqual
        
        q = Quaternion()
        self.assertTrue(q.lengthSquared == 1.0)
        
        q = Quaternion(1.,2.,3.,4.)
        self.assertTrue(q.lengthSquared != 1.0)
        
        q.unit()
        eq(q.lengthSquared, 1.)
    
    def test_mul(self):
        eq = self.assertAlmostEqual
        
        q1 = Quaternion.fromAngleAxis(math.radians(90.),Vector(0.,0.,1.))
        q2 = Quaternion.fromAngleAxis(math.radians(-90.),Vector(0.,0.,1.))
        
        q3 = q1*q2
        
        eq(q3.w, 1.)
        eq(q3.x, 0.)
        eq(q3.y, 0.)
        eq(q3.z, 0.)
    
    def test_imul(self):
        eq = self.assertAlmostEqual
        
        q1 = Quaternion.fromAngleAxis(math.radians(90.),Vector(0.,0.,1.))
        q2 = Quaternion.fromAngleAxis(math.radians(-90.),Vector(0.,0.,1.))
        
        q1 *= q2
        
        eq(q1.w, 1.)
        eq(q1.x, 0.)
        eq(q1.y, 0.)
        eq(q1.z, 0.)
    
    def test_unit(self):
        eq = self.assertAlmostEqual
        
        q = Quaternion(1.,2.,3.,4.)
        self.assertTrue(q.length != 1.0)
        
        q.unit()
        
        eq(q.length, 1.)
    
    def test_conj(self):
        eq = self.assertAlmostEqual
        
        q = Quaternion(1.,2.,3.,4.)
        q.conj()
        
        self.assertTrue(q.w == 1.)
        self.assertTrue(q.x == -2.)
        self.assertTrue(q.y == -3.)
        self.assertTrue(q.z == -4.)
    
    def test_map(self):
        eq = self.assertAlmostEqual
        
        q = Quaternion.fromAngleAxis(math.radians(90.),Vector(0.,0.,1.))
        
        p = q.map((1.,0.,0.))
        
        eq(p[0], 0.)
        eq(p[1], 1.)
        eq(p[2], 0.)
    
    def test_imap(self):
        eq = self.assertAlmostEqual
        
        q = Quaternion.fromAngleAxis(math.radians(90.),Vector(0.,0.,1.))
        
        p = q.imap((1.,0.,0.))
        
        eq(p[0], 0.)
        eq(p[1], -1.)
        eq(p[2], 0.)
    
    def test_transform(self):
        eq = self.assertAlmostEqual
        
        q = Quaternion.fromAngleAxis(math.radians(90.),Vector(0.,0.,1.))
        
        a = q.map((1.,0.,0.))
        
        tr = q.transform
        b = tr.map((1.,0.,0.))
        
        eq(a[0], b[0])
        eq(a[1], b[1])
        eq(a[2], b[2])

if __name__ == "__main__":
    sys.dont_write_bytecode = True
    unittest.main()