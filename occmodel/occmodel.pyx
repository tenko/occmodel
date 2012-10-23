# -*- coding: utf-8 -*-
#cython: embedsignature=True
# Copyright 2012 by Runar Tenfjord, Tenko as.
# See LICENSE.txt for details on conditions.
include "OCCIncludes.pxi"

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
            
include "OCCTools.pxi"
include "OCCBase.pxi"
include "OCCVertex.pxi"
include "OCCEdge.pxi"
include "OCCWire.pxi"
include "OCCFace.pxi"
include "OCCSolid.pxi"