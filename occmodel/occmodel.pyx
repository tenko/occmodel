# -*- coding: utf-8 -*-
#cython: embedsignature=True
from libc.stdlib cimport malloc, free
from libc.math cimport fmin, fmax, fabs, copysign
from libc.math cimport M_PI, sqrt, sin, cos, tan

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

cdef class Mesh:
    '''
    Mesh - Represent triangle mesh for viewing purpose
    '''
    cdef void *thisptr
    
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
        args = self.nvertices(), self.ntriangles()
        return "(nvertices = %d, ntriangles = %d)" % args
    
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
    
    cpdef vertex(self, size_t index):
        '''
        Return vertex at given index
        '''
        cdef c_OCCMesh *occ = <c_OCCMesh *>self.thisptr
        cdef vector[double] v = occ.vertices[index]
        return v[0], v[1], v[2]
    
    cpdef normal(self, size_t index):
        '''
        Return normal at given vertex index
        '''
        cdef c_OCCMesh *occ = <c_OCCMesh *>self.thisptr
        cdef vector[double] n = occ.normals[index]
        return n[0], n[1], n[2]
        
    cpdef triangle(self, size_t index):
        '''
        Return triangle indices at given index
        '''
        cdef c_OCCMesh *occ = <c_OCCMesh *>self.thisptr
        cdef vector[int] t = occ.triangles[index]
        return t[0], t[1], t[2]
    
    cpdef GLVertices(self):
        '''
        Apply function pointer 'glVertex3d' to
        all vertices in mesh.
        '''
        cdef c_OCCMesh *occ = <c_OCCMesh *>self.thisptr
        cdef vector[double] v
        cdef size_t i
        
        for i in range(occ.vertices.size()):
            v = occ.vertices[i]
            glVertex3d(v[0], v[1], v[2])
    
    cpdef GLTriangles(self):
        '''
        Apply function pointer 'glVertex3d' and
        'glNormal3d' to all triangles in mesh.
        '''
        cdef c_OCCMesh *occ = <c_OCCMesh *>self.thisptr
        cdef vector[int] triangle
        cdef vector[double] a, b, c
        cdef vector[double] na, nb, nc
        cdef double nx, ny, nz, ll
        cdef size_t i
        
        for i in range(occ.triangles.size()):
            triangle = occ.triangles[i]
            a = occ.vertices[triangle[0]]
            b = occ.vertices[triangle[1]]
            c = occ.vertices[triangle[2]]
            
            na = occ.normals[triangle[0]]
            nb = occ.normals[triangle[1]]
            nc = occ.normals[triangle[2]]
            
            glNormal3d(na[0],na[1],na[2])
            glVertex3d(a[0],a[1],a[2])
            
            glNormal3d(nb[0],nb[1],nb[2])
            glVertex3d(b[0],b[1],b[2])
            
            glNormal3d(nc[0],nc[1],nc[2])
            glVertex3d(c[0],c[1],c[2])
        
include "Vertex.pxi"
include "Edge.pxi"
include "Wire.pxi"
include "Face.pxi"
include "Solid.pxi"