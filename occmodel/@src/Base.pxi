# -*- coding: utf-8 -*-

cdef class Base:
    '''
    Definition of virtual base object
    '''
    cdef void *thisptr
    
    def __str__(self):
        return 'Base%s' % self.__repr__()
    
    def __repr__(self):
        return '()'
    
    def __richcmp__(self, other, int op):
        if op == 2:
            return self.isEqual(other)
        elif op == 3:
            return not self.isEqual(other)
        else:
            raise TypeError('operation not supported')
            
    cpdef CheckPtr(self):
        if self.thisptr == NULL:
            raise TypeError('Base object not initialized')
    
    cpdef bint isEqual(self, Base other):
        '''
        Check object for equallity
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.isEqual(<c_OCCBase *>other.thisptr)
    
    cpdef bint isNull(self):
        '''
        Check if object is empty.
        '''
        self.CheckPtr()
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.isNull()
        
    cpdef bint isValid(self):
        '''
        Return if object is valid
        '''
        self.CheckPtr()
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.isValid()
        
    cpdef Box boundingBox(self, double tolerance = 1e-12):
        '''
        Return bounding box
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef vector[double] bbox = occ.boundingBox(tolerance)
        cdef Box ret = Box.__new__(Box, None)
        
        ret.near = Point(bbox[0], bbox[1], bbox[2])
        ret.far = Point(bbox[3], bbox[4], bbox[5])
        return ret
    
    cpdef transform(self, Transform mat):
        '''
        Set transformation matrix for object.
        
        mat - Transformation matrix
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef vector[double] cmat
        cdef int ret
        
        cmat.push_back(mat.m[0][0])
        cmat.push_back(mat.m[0][1])
        cmat.push_back(mat.m[0][2])
        cmat.push_back(mat.m[0][3])
        
        cmat.push_back(mat.m[1][0])
        cmat.push_back(mat.m[1][1])
        cmat.push_back(mat.m[1][2])
        cmat.push_back(mat.m[1][3])
        
        cmat.push_back(mat.m[2][0])
        cmat.push_back(mat.m[2][1])
        cmat.push_back(mat.m[2][2])
        cmat.push_back(mat.m[2][3])
        
        ret = occ.transform(cmat)
        if ret != 0:
            raise OCCError('Failed to transform object')
            
        return self
        
    cpdef translate(self, delta):
        '''
        Translate object in place.
        
        delta - (dx,dy,dz)
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef vector[double] cdelta
        cdef int ret
        
        cdelta.push_back(delta[0])
        cdelta.push_back(delta[1])
        cdelta.push_back(delta[2])
        
        ret = occ.translate(cdelta)
        if ret != 0:
            raise OCCError('Failed to translate object')
            
        return self
    
    cpdef rotate(self, p1, p2, angle):
        '''
        Rotate object in place.
        
        p1 - axis start point
        p2 - axis end point
        angle - rotation angle in radians
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
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
            raise OCCError('Failed to rotate object')
            
        return self

    cpdef scale(self, pnt, double scale):
        '''
        Scale object in place.
        
        pnt - reference point
        scale - scale factor
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef vector[double] cpnt
        cdef int ret
        
        cpnt.push_back(pnt[0])
        cpnt.push_back(pnt[1])
        cpnt.push_back(pnt[2])
        
        ret = occ.scale(cpnt, scale)
        if ret != 0:
            raise OCCError('Failed to scale object')
            
        return self
    
    cpdef mirror(self, Plane plane):
        '''
        Mirror object inplace
        
        plane - mirror plane
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
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
            raise OCCError('Failed to mirror object')
            
        return self
