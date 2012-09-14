# -*- coding: utf-8 -*-

cdef class Wire:
    '''
    Wire - represent wire geometry (composite curve forming face border).
    '''
    cdef void *thisptr
    
    def __init__(self):
        self.thisptr = new c_OCCWire()
      
    def __dealloc__(self):
        cdef c_OCCWire *tmp
        
        if self.thisptr != NULL:
            tmp = <c_OCCWire *>self.thisptr
            del tmp
    
    cdef void *getNativePtr(self):
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
        return occ.getNativePtr()
        
    def __str__(self):
        return "Wire%s" % repr(self)
    
    def __repr__(self):
        return "()"
    
    cpdef Wire copy(self):
        '''
        Create copy of wire
        '''
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
        cdef Wire ret = Wire.__new__(Wire, None)
        ret.thisptr = occ.copy()
        return ret
    
    cpdef createWire(self, edges):
        '''
        Create wire by connecting edges.
        '''
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
        cdef vector[c_OCCEdge *] cedges
        cdef Edge edge
        cdef int ret
        
        for edge in edges:
            cedges.push_back((<c_OCCEdge *>edge.thisptr))
        
        ret = occ.createWire(cedges)
            
        if ret != 0:
            raise OCCError('Failed to loft wires')
            
        return self
        
    cpdef Box boundingBox(self):
        '''
        Return wire bounding box
        '''
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
        cdef vector[double] bbox = occ.boundingBox()
        cdef Box ret = Box.__new__(Box, None)
        ret.near = Point(bbox[0], bbox[1], bbox[2])
        ret.far = Point(bbox[3], bbox[4], bbox[5])
        return ret
    
    cpdef tesselate(self, double factor = .1, double angle = .1):
        '''
        Tesselate wire to a tuple of points according to given
        max angle or distance factor
        '''
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
        cdef vector[vector[double]] pnts
        cdef size_t i, size
        
        pnts = occ.tesselate(factor, angle)
        
        size = pnts.size()
        if size < 2:
            raise OCCError('Failed to tesselate wire')
        
        ret = [(pnts[i][0], pnts[i][1], pnts[i][2]) for i in range(size)]
        
        return tuple(ret)
        
    cpdef translate(self, delta):
        '''
        Translate wire in place.
        
        delta - (dx,dy,dz)
        '''
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
        cdef vector[double] cdelta
        cdef int ret
        
        cdelta.push_back(delta[0])
        cdelta.push_back(delta[1])
        cdelta.push_back(delta[2])
        
        ret = occ.translate(cdelta)
        if ret != 0:
            raise OCCError('Failed to translate wire')
            
        return self
    
    cpdef rotate(self, p1, p2, angle):
        '''
        Rotate wire in place.
        
        p1 - axis start point
        p2 - axis end point
        angle - rotation angle in radians
        '''
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
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
            raise OCCError('Failed to rotate wire')
            
        return self

    cpdef scale(self, pnt, double scale):
        '''
        Scale wire in place.
        
        pnt - reference point
        scale - scale factor
        '''
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
        cdef vector[double] cpnt
        cdef int ret
        
        cpnt.push_back(pnt[0])
        cpnt.push_back(pnt[1])
        cpnt.push_back(pnt[2])
        
        ret = occ.scale(cpnt, scale)
        if ret != 0:
            raise OCCError('Failed to scale wire')
            
        return self
    
    cpdef mirror(self, Plane plane):
        '''
        Mirror wire inplace
        
        plane - mirror plane
        '''
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
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
            raise OCCError('Failed to mirror wire')
            
        return self

    cpdef double length(self):
        '''
        Return wire length
        '''
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
        return occ.length()