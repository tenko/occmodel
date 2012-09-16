# -*- coding: utf-8 -*-

cdef class Vertex:
    '''
    Vertex
    '''
    cdef void *thisptr
    
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
    
    cpdef translate(self, delta):
        '''
        Translate vertex in place.
        
        delta - (dx,dy,dz)
        '''
        cdef c_OCCVertex *occ = <c_OCCVertex *>self.thisptr
        cdef vector[double] cdelta
        cdef int ret
        
        cdelta.push_back(delta[0])
        cdelta.push_back(delta[1])
        cdelta.push_back(delta[2])
        
        ret = occ.translate(cdelta)
        if ret != 0:
            raise OCCError('Failed to translate vertex')
            
        return self
    
    cpdef rotate(self, p1, p2, angle):
        '''
        Rotate vertex in place.
        
        p1 - axis start point
        p2 - axis end point
        angle - rotation angle in radians
        '''
        cdef c_OCCVertex *occ = <c_OCCVertex *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.rotate(cp1, cp2, angle)
        if ret != 0:
            raise OCCError('Failed to rotate vertex')
            
        return self

    cpdef scale(self, pnt, double scale):
        '''
        Scale vertex in place.
        
        pnt - reference point
        scale - scale factor
        '''
        cdef c_OCCVertex *occ = <c_OCCVertex *>self.thisptr
        cdef vector[double] cpnt
        cdef int ret
        
        cpnt.push_back(pnt[0])
        cpnt.push_back(pnt[1])
        cpnt.push_back(pnt[2])
        
        ret = occ.scale(cpnt, scale)
        if ret != 0:
            raise OCCError('Failed to scale vertex')
            
        return self
    
    cpdef mirror(self, Plane plane):
        '''
        Mirror vertex inplace
        
        plane - mirror plane
        '''
        cdef c_OCCVertex *occ = <c_OCCVertex *>self.thisptr
        cdef vector[double] cpnt, cnor
        cdef int ret
        
        cpnt.push_back(plane.origin.x)
        cpnt.push_back(plane.origin.y)
        cpnt.push_back(plane.origin.z)
        
        cnor.push_back(plane.zaxis.x)
        cnor.push_back(plane.zaxis.y)
        cnor.push_back(plane.zaxis.z)
        
        ret = occ.mirror(cpnt, cnor)
        if ret != 0:
            raise OCCError('Failed to mirror vertex')
            
        return self