# -*- coding: utf-8 -*-

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
        return "(%g,%g,%g)" % (self.x(), self.y(), self.z())
    
    cpdef double x(self):
        cdef c_OCCVertex *occ = <c_OCCVertex *>self.thisptr
        return occ.x()
    
    cpdef double y(self):
        cdef c_OCCVertex *occ = <c_OCCVertex *>self.thisptr
        return occ.y()
    
    cpdef double z(self):
        cdef c_OCCVertex *occ = <c_OCCVertex *>self.thisptr
        return occ.z()