# -*- coding: utf-8 -*-
#cython: embedsignature=True
# Copyright 2012 by Runar Tenfjord, Tenko as.
# See LICENSE.txt for details on conditions.
from libc.stdlib cimport malloc, free
from libc.math cimport fmin, fmax, fabs, copysign
from libc.math cimport M_PI, sqrt, sin, cos, tan

from cython cimport view

cdef extern from "math.h":
    bint isnan(double x)
    
from OCCModelLib cimport *

import sys
import itertools

# constants
cdef double EPSILON = 2.2204460492503131e-16
cdef double SQRT_EPSILON = 1.490116119385000000e-8
cdef double ZERO_TOLERANCE = 1.0e-12
cdef double DEFAULT_ANGLE_TOLERANCE = M_PI/180.

# base classes
include "Utilities.pxi"
include "Point.pxi"
include "Vector.pxi"
include "Quaternion.pxi"
include "Box.pxi"
include "Plane.pxi"
include "Transform.pxi"

# visual classes
include "GL.pxi"
include "GLUT.pxi"
include "Viewer.pxi"

class OCCError(Exception):
    pass

cdef class Tesselation:
    '''
    Tesselation - Representing Edge/Wire tesselation which result in
                  possible multiple disconnected polylines.
    '''
    cdef void *thisptr
    
    cdef readonly view.array vertices
    cdef readonly int verticesItemSize
    
    cdef readonly view.array ranges
    cdef readonly int rangesItemSize
    
    def __init__(self):
        self.thisptr = new c_OCCTesselation()
        
    def __dealloc__(self):
        cdef c_OCCTesselation *tmp
        
        if self.thisptr != NULL:
            tmp = <c_OCCTesselation *>self.thisptr
            del tmp
    
    def __str__(self):
        return "Tesselation%s" % repr(self)
    
    def __repr__(self):
        args = self.nvertices(), self.nranges()
        return "(nvertices = %d, ranges = %d)" % args
    
    cdef setArrays(self):
        cdef c_OCCTesselation *occ = <c_OCCTesselation *>self.thisptr
        
        self.verticesItemSize = sizeof(float)
        self.rangesItemSize = sizeof(unsigned int)
        
        self.vertices = view.array(
            shape=(3*occ.vertices.size(),),
            itemsize=sizeof(float),
            format="f",
            allocate_buffer=False
        )
        self.vertices.data = <char *> &occ.vertices[0]
        
        self.ranges = view.array(
            shape=(occ.ranges.size(),),
            itemsize=sizeof(unsigned int),
            format="I",
            allocate_buffer=False
        )
        self.ranges.data = <char *> &occ.ranges[0]
      
    cpdef size_t nvertices(self):
        '''
        Return number of vertices
        '''
        cdef c_OCCTesselation *occ = <c_OCCTesselation *>self.thisptr
        return occ.vertices.size()
        
    cpdef size_t nranges(self):
        '''
        Return number of range values
        '''
        cdef c_OCCTesselation *occ = <c_OCCTesselation *>self.thisptr
        return occ.ranges.size()
        
    
cdef class Mesh:
    '''
    Mesh - Represent triangle mesh for viewing purpose
    '''
    cdef void *thisptr
    
    cdef readonly view.array vertices
    cdef readonly int verticesItemSize
    
    cdef readonly view.array normals
    cdef readonly int normalsItemSize
    
    cdef readonly view.array triangles
    cdef readonly int trianglesItemSize
    
    def __init__(self):
        self.thisptr = new c_OCCMesh()
        
    def __dealloc__(self):
        cdef c_OCCMesh *tmp
        
        if self.thisptr != NULL:
            tmp = <c_OCCMesh *>self.thisptr
            del tmp
    
    def __str__(self):
        return "Mesh%s" % repr(self)
    
    def __repr__(self):
        args = self.nvertices(), self.ntriangles(), self.nnormals()
        return "(nvertices = %d, ntriangles = %d, nnormals = %d)" % args
    
    cdef setArrays(self):
        cdef c_OCCMesh *occ = <c_OCCMesh *>self.thisptr
        
        self.verticesItemSize = sizeof(float)
        self.normalsItemSize = sizeof(float)
        self.trianglesItemSize = sizeof(unsigned int)
        
        self.vertices = view.array(
            shape=(3*occ.vertices.size(),),
            itemsize=sizeof(float),
            format="f",
            allocate_buffer=False
        )
        self.vertices.data = <char *> &occ.vertices[0]
        
        self.normals = view.array(
            shape=(3*occ.normals.size(),),
            itemsize=sizeof(float),
            format="f",
            allocate_buffer=False
        )
        self.normals.data = <char *> &occ.normals[0]
        
        self.triangles = view.array(
            shape=(3*occ.triangles.size(),),
            itemsize=sizeof(unsigned int),
            format="I",
            allocate_buffer=False
        )
        self.triangles.data = <char *> &occ.triangles[0]
      
    cpdef size_t nvertices(self):
        '''
        Return number of vertices
        '''
        cdef c_OCCMesh *occ = <c_OCCMesh *>self.thisptr
        return occ.vertices.size()
        
    cpdef size_t ntriangles(self):
        '''
        Return number of triangles
        '''
        cdef c_OCCMesh *occ = <c_OCCMesh *>self.thisptr
        return occ.triangles.size()
    
    cpdef size_t nnormals(self):
        '''
        Return number of normals
        '''
        cdef c_OCCMesh *occ = <c_OCCMesh *>self.thisptr
        return occ.normals.size()
        
    cpdef vertex(self, size_t index):
        '''
        Return vertex at given index
        '''
        cdef c_OCCMesh *occ = <c_OCCMesh *>self.thisptr
        cdef c_OCCStruct3f v = occ.vertices[index]
        return v.x, v.y, v.z
    
    cpdef normal(self, size_t index):
        '''
        Return normal at given vertex index
        '''
        cdef c_OCCMesh *occ = <c_OCCMesh *>self.thisptr
        cdef c_OCCStruct3f n = occ.normals[index]
        return n.x, n.y, n.z
        
    cpdef triangle(self, size_t index):
        '''
        Return triangle indices at given index
        '''
        cdef c_OCCMesh *occ = <c_OCCMesh *>self.thisptr
        cdef c_OCCStruct3I t = occ.triangles[index]
        return t.i, t.j, t.k
    
    cpdef GLVertices(self):
        '''
        Apply function pointer 'glVertex3d' to
        all vertices in mesh.
        '''
        cdef c_OCCMesh *occ = <c_OCCMesh *>self.thisptr
        cdef c_OCCStruct3f v
        cdef size_t i
        
        for i in range(occ.vertices.size()):
            v = occ.vertices[i]
            glVertex3d(v.x, v.y, v.z)
    
    cpdef GLTriangles(self):
        '''
        Apply function pointer 'glVertex3d' and
        'glNormal3d' to all triangles in mesh.
        '''
        cdef c_OCCMesh *occ = <c_OCCMesh *>self.thisptr
        cdef c_OCCStruct3I triangle
        cdef c_OCCStruct3f a, b, c
        cdef c_OCCStruct3f na, nb, nc
        cdef double nx, ny, nz, ll
        cdef size_t i
        
        for i in range(occ.triangles.size()):
            triangle = occ.triangles[i]
            a = occ.vertices[triangle.i]
            b = occ.vertices[triangle.j]
            c = occ.vertices[triangle.k]
            
            na = occ.normals[triangle.i]
            nb = occ.normals[triangle.j]
            nc = occ.normals[triangle.k]
            
            glNormal3d(na.x,na.y,na.z)
            glVertex3d(a.x,a.y,a.z)
            
            glNormal3d(nb.x,nb.y,nb.z)
            glVertex3d(b.x,b.y,b.z)
            
            glNormal3d(nc.x,nc.y,nc.z)
            glVertex3d(c.x,c.y,c.z)        
            
include "OCCTools.pxi"
include "OCCBase.pxi"
include "OCCVertex.pxi"
include "OCCEdge.pxi"
include "OCCWire.pxi"
include "OCCFace.pxi"
include "OCCSolid.pxi"