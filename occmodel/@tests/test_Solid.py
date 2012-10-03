#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import unittest

from math import pi, sin, cos, sqrt

from occmodel import Vertex, Edge, Face, Solid

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
        
        eq(s3.area(), 2.*4.*pi, places = 3)
        eq(s3.volume(), 2.*4./3.*pi, places = 3)
    
    def test_createSphere(self):
        eq = self.assertAlmostEqual
        
        solid = Solid()
        solid.createSphere((0.,0.,0.),1.)
        
        eq(solid.area(), 4.*pi, places = 3)
        eq(solid.volume(), 4./3.*pi, places = 3)
        
    def test_createCylinder(self):
        eq = self.assertAlmostEqual
        
        solid = Solid()
        solid.createCylinder((0.,0.,0.),(0.,0.,1.), 1.)
        
        eq(solid.area(), 4.*pi, places = 3)
        eq(solid.volume(), pi, places = 3)
        
if __name__ == "__main__":
    sys.dont_write_bytecode = True
    unittest.main()