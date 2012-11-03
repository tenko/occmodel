# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#

JOINTYPE_ARC = 0
JOINTYPE_TANGENT = 1
JOINTYPE_INTERSECTION = 2

cdef class Base:
    '''
    Definition of virtual base object
    '''
    cdef void *thisptr
    
    def __str__(self):
        return 'Base%s' % self.__repr__()
    
    def __repr__(self):
        return '()'
    
    def __hash__(self):
        return self.hashCode()
        
    def __richcmp__(self, other, int op):
        if not isinstance(other, Base):
            if op == 2:
                return False
            elif op == 3:
                return True
            else:
               raise TypeError('operation not supported')
        else:
            if op == 2:
                return self.hashCode() == other.hashCode()
            elif op == 3:
                return self.hashCode() != other.hashCode()
            else:
                raise TypeError('operation not supported')
                
    cdef CheckPtr(self):
        if self.thisptr == NULL:
            raise TypeError('Base object not initialized')
    
    cpdef shapeType(self):
        '''
        Return class type or None if shape not known.
        '''
        self.CheckPtr()
        
        if self.isNull():
            raise OCCError('No type defined for Null shape')
            
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef c_TopAbs_ShapeEnum shapetype = occ.shapeType()
            
        if shapetype == TopAbs_COMPSOLID or \
           shapetype == TopAbs_SOLID:
               return Solid
        elif shapetype == TopAbs_SHELL or \
           shapetype == TopAbs_FACE:
               return Face
        elif shapetype == TopAbs_WIRE:
               return Wire
        elif shapetype == TopAbs_EDGE:
               return Edge
        elif shapetype == TopAbs_VERTEX:
               return Vertex
        else:
            return None
            
    cpdef int hashCode(self):
        '''
        Shape hash code.
        
        Orientation is not included in the hash calculation. Instances of
        the same object therfore return the same hash code.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.hashCode()
        
    cpdef bint isEqual(self, Base other):
        '''
        Check object for equallity. Returns True only if both the
        underlying geometry and location is similar.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.isEqual(<c_OCCBase *>other.thisptr)
    
    cpdef bint isNull(self):
        '''
        Check if object is Null.
        '''
        self.CheckPtr()
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.isNull()
        
    cpdef bint isValid(self):
        '''
        Return if object is valid.
        '''
        self.CheckPtr()
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.isValid()
    
    cpdef bint hasPlane(self, Point origin = None, Vector normal = None, double tolerance = 1e-12):
        '''
        Check if object has plane defined. Optional pass origin and normal
        argument to fetch the plane definition.
        
        :param origin: Plane origin
        :param normal: Plane normal
        :param tolerance: Plane tolerance
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef c_OCCStruct3d corigin, cnormal
        
        if occ.findPlane(&corigin, &cnormal, tolerance) == 0:
            return False
        
        if not normal is None:
            normal.set(cnormal.x, cnormal.y, cnormal.z)
        
        if not origin is None:
            origin.set(corigin.x, corigin.y, corigin.z)
            
        return True
        
    cpdef AABBox boundingBox(self, double tolerance = 1e-12):
        '''
        Return bounding box
        
        :param tolerance: Tolerance of calculation.
        '''
        self.CheckPtr()
            
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef vector[double] bbox = occ.boundingBox(tolerance)
        cdef AABBox ret = AABBox.__new__(AABBox, None)
        
        ret.min = Point(bbox[0], bbox[1], bbox[2])
        ret.max = Point(bbox[3], bbox[4], bbox[5])
        
        return ret
    
    cpdef transform(self, Transform mat, bint copy = False):
        '''
        Apply transformation matrix to object.
        
        :param mat: Transformation matrix
        :param copy: If True the object is translated in place otherwise a
                     new translated object is returned.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef Base target
        cdef vector[double] cmat
        cdef int ret
        
        if copy:
            target = self.__class__()
        else:
            target = self
            
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
        
        ret = occ.transform(cmat, <c_OCCBase *>target.thisptr)
        if not ret:
            raise OCCError(errorMessage)
            
        return target
        
    cpdef translate(self, delta, bint copy = False):
        '''
        Translate object.
        
        :param delta: translation vector (dx,dy,dz)
        :param copy: If True the object is translated in place otherwise a
                     new translated object is returned.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef Base target
        cdef c_OCCStruct3d cdelta
        cdef int ret
        
        if copy:
            target = self.__class__()
        else:
            target = self
        
        cdelta.x = delta[0]
        cdelta.y = delta[1]
        cdelta.z = delta[2]
        
        ret = occ.translate(cdelta, <c_OCCBase *>target.thisptr)
        if not ret:
            raise OCCError(errorMessage)
            
        return target
    
    cpdef rotate(self, double angle, axis, center = (0.,0.,0.), bint copy = False):
        '''
        Rotate object.
        
        :param angle: rotation angle in radians
        :param axis: axis vector
        :param center: rotation center
        :param copy: If True the object is transformed in place otherwise a
                     new transformed object is returned.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef Base target
        cdef c_OCCStruct3d cp1, cp2
        cdef int ret
        
        if copy:
            target = self.__class__()
        else:
            target = self
        
        axis = Vector(axis)
        p1 = Point(center)
        p2 = p1 + axis
        
        cp1.x = p1.x
        cp1.y = p1.y
        cp1.z = p1.z
        
        cp2.x = p2.x
        cp2.y = p2.y
        cp2.z = p2.z
        
        ret = occ.rotate(angle, cp1, cp2, <c_OCCBase *>target.thisptr)
        if not ret:
            raise OCCError(errorMessage)
            
        return target

    cpdef scale(self, pnt, double scale, bint copy = False):
        '''
        Scale object.
        
        :param pnt: reference point
        :param scale: scale factor
        :param copy: If True the object is translated in place otherwise a
                     new translated object is returned.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef Base target
        cdef c_OCCStruct3d cpnt
        cdef int ret
        
        if copy:
            target = self.__class__()
        else:
            target = self
            
        cpnt.x = pnt[0]
        cpnt.y = pnt[1]
        cpnt.z = pnt[2]
        
        ret = occ.scale(cpnt, scale, <c_OCCBase *>target.thisptr)
        if not ret:
            raise OCCError(errorMessage)
            
        return target

    cpdef mirror(self, Plane plane, bint copy = False):
        '''
        Mirror object
        
        :param plane: mirror plane
        :param copy: If True the object is translated in place otherwise a
                     new translated object is returned.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef Base target
        cdef c_OCCStruct3d cpnt, cnor
        cdef int ret
        
        if copy:
            target = self.__class__()
        else:
            target = self
            
        cpnt.x = plane.origin.x
        cpnt.y = plane.origin.y
        cpnt.z = plane.origin.z
        
        cnor.x = plane.zaxis.x
        cnor.y = plane.zaxis.y
        cnor.z = plane.zaxis.z
        
        ret = occ.mirror(cpnt, cnor, <c_OCCBase *>target.thisptr)
        if not ret:
            raise OCCError(errorMessage)
            
        return target
        
    cpdef toString(self):
        '''
        Seralize object to string.
        
        The format used is the OpenCASCADE internal BREP format.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef string res = string()
        
        occ.toString(&res)
        ret = str(res.c_str())
        
        return ret
    
    cpdef fromString(self, char *st):
        '''
        Restore shape from string.
        
        The format used is the OpenCASCADE internal BREP format.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef string cst= string(st)
        
        if not occ.fromString(cst):
            raise OCCError(errorMessage)
        
        return self