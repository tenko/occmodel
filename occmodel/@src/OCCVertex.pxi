# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#

cdef class Vertex(Base):
    '''
    Vertex
    '''
    def __init__(self, double x = 0., double y = 0., double z = 0.):
        self.thisptr = new c_OCCVertex(x,y,z)
      
    def __dealloc__(self):
        cdef c_OCCVertex *tmp
        
        if self.thisptr != NULL:
            tmp = <c_OCCVertex *>self.thisptr
            del tmp
        
    def __str__(self):
        return "Vertex%s" % repr(self)
    
    def __repr__(self):
        return "(%g,%g,%g)" % (self.X(), self.Y(), self.Z())
    
    def __getitem__(self, int key):
        if key == 0:
            return self.X()
        elif key == 1:
            return self.Y()
        elif key == 2:
            return self.Z()
        raise IndexError('index out of range')
    
    def __len__(self):
        return 3
    
    property x:
        def __get__(self):
            return self.X()
    
    property y:
        def __get__(self):
            return self.Y()
    
    property z:
        def __get__(self):
            return self.Z()
            
    cpdef double X(self):
        cdef c_OCCVertex *occ = <c_OCCVertex *>self.thisptr
        return occ.X()
    
    cpdef double Y(self):
        cdef c_OCCVertex *occ = <c_OCCVertex *>self.thisptr
        return occ.Y()
    
    cpdef double Z(self):
        cdef c_OCCVertex *occ = <c_OCCVertex *>self.thisptr
        return occ.Z()

cdef class VertexIterator:
    '''
    Iterator of vertices
    '''
    cdef c_OCCVertexIterator *thisptr
    cdef set seen
    cdef bint includeAll
    
    def __init__(self, Base arg, bint includeAll = False):
        self.thisptr = new c_OCCVertexIterator(<c_OCCBase *>arg.thisptr)
        self.includeAll = includeAll
        self.seen = set()
        
    def __dealloc__(self):
        del self.thisptr
            
    def __str__(self):
        return 'VertexIterator%s' % self.__repr__()
    
    def __repr__(self):
        return '()'
    
    def __iter__(self):
        return self
    
    def __next__(self):
        cdef c_OCCVertex *nxt
        cdef int hash
        
        while True:
            nxt = self.thisptr.next()
            if nxt == NULL:
                raise StopIteration()
            
            if self.includeAll:
                break
            else:
                # check for duplicate (same vertex different orientation)
                hash = (<c_OCCBase *>nxt).hashCode()
                if hash in self.seen:
                    continue
                else:
                    self.seen.add(hash)
                    break
        
        cdef Vertex ret = Vertex.__new__(Vertex, 0.,0.,0.)
        ret.thisptr = nxt
        return ret
    
    cpdef reset(self):
        '''Restart iteration'''
        self.thisptr.reset()