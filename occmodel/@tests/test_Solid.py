#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#
import sys
import unittest

from math import pi, sin, cos, sqrt

from occmodel import Vertex, Edge, Face, Solid, OCCError

class test_Solid(unittest.TestCase):
    def almostEqual(self, a, b, places = 7):
        for va,vb in zip(a,b):
            self.assertAlmostEqual(va, vb, places)
            
    def test_centreOfMass(self):
        eq = self.almostEqual
        
        solid = Solid()
        solid.createSphere((0.,0.,0.),1.)
        
        eq(solid.centreOfMass(), (0.,0.,0.))
    
    def test_translate(self):
        eq = self.almostEqual
        
        solid = Solid()
        solid.createSphere((0.,0.,0.),1.)
        solid.translate((1.,2.,3.))
        eq(solid.centreOfMass(), (1.,2.,3.))
    
    def test_rotate(self):
        eq = self.almostEqual
        
        solid = Solid()
        solid.createSphere((0.,0.,0.),1.)
        solid.rotate(-pi/2., (0.,1.,0.),(1.,1.,0.))
        eq(solid.centreOfMass(), (1.,0.,-1.))
    
    def test_scale(self):
        eq = self.assertAlmostEqual
        
        scale = .5
        solid = Solid()
        solid.createSphere((0.,0.,0.),1.)
        solid.scale((0.,0.,0.), scale)
        
        #eq(solid.area(), scale*4.*pi, places = 3)
        #eq(solid.volume(), scale*4./3.*pi, places = 3)
    
    def test_addSolids(self):
        eq = self.assertAlmostEqual
        
        s1 = Solid().createSphere((0.,0.,0.),1.)
        s2 = Solid().createSphere((2.,0.,0.),1.)
        s3 = Solid().addSolids((s1,s2))
        
        self.assertEqual(s3.numSolids(), 2)
        eq(s3.area(), 2.*4.*pi, places = 3)
        eq(s3.volume(), 2.*4./3.*pi, places = 3)
        
        s1 = Solid().createSphere((0.,0.,0.),.5)
        self.assertEqual(s1.numSolids(), 1)
        s2 = Solid().createSphere((2.,0.,0.),.5)
        s1.addSolids(s2)
        self.assertEqual(s1.numSolids(), 2)
        s3 = Solid().createSphere((4.,0.,0.),.5)
        s1.addSolids(s3)
        self.assertEqual(s1.numSolids(), 3)
    
    def test_createSphere(self):
        eq = self.assertAlmostEqual
        
        self.assertRaises(OCCError, Solid().createSphere, (0.,0.,0.),0.)
        self.assertRaises(OCCError, Solid().createSphere, (0.,0.,0.),-1.)
        
        solid = Solid()
        solid.createSphere((0.,0.,0.),1.)
        
        eq(solid.area(), 4.*pi, places = 3)
        eq(solid.volume(), 4./3.*pi, places = 3)
        
    def test_createCylinder(self):
        eq = self.assertAlmostEqual
        
        self.assertRaises(OCCError, Solid().createCylinder, (0.,0.,0.),(0.,0.,1.), 0.)
        self.assertRaises(OCCError, Solid().createCylinder, (0.,0.,0.),(0.,0.,1.), -1.)
        
        solid = Solid()
        solid.createCylinder((0.,0.,0.),(0.,0.,1.), 1.)
        
        eq(solid.area(), 4.*pi, places = 3)
        eq(solid.volume(), pi, places = 3)
    
    def test_createTorus(self):
        eq = self.assertAlmostEqual
        
        self.assertRaises(OCCError, Solid().createTorus, (0.,0.,0.),(0.,0.,.1), 0., 1.)
        self.assertRaises(OCCError, Solid().createTorus, (0.,0.,0.),(0.,0.,.1), 1., 0.)
        
        solid = Solid()
        solid.createTorus((0.,0.,0.),(0.,0.,.1), 2., 1.)
        
        eq(solid.area(), 4.*pi**2*2.*1., places = 1)
        eq(solid.volume(), 2.*pi**2*2.*1.**2, places = 3)
    
    def test_createTorus(self):
        eq = self.assertAlmostEqual
        
        self.assertRaises(OCCError, Solid().createCone, (0.,0.,0.),(0.,0.,1.), 0., 0.)
        self.assertRaises(OCCError, Solid().createCone, (0.,0.,0.),(0.,0.,1.), 1., 1.)
        
        solid = Solid()
        solid.createCone((0.,0.,0.),(0.,0.,.1), 2., 1.)
        
        self.assertEqual(solid.volume() > 0., True)
    
    def test_createBox(self):
        eq = self.assertAlmostEqual
        
        self.assertRaises(OCCError, Solid().createBox, (-.5,-.5,-.5),(-.5,-.5,-.5))
        
        solid = Solid()
        solid.createBox((-.5,-.5,-.5),(.5,.5,.5))
        
        eq(solid.volume(), 1.)
        
if __name__ == "__main__":
    sys.dont_write_bytecode = True
    unittest.main()