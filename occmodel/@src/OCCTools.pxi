# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#

cdef class Tools:
    '''
    Misc tools.
    '''
    @staticmethod
    def writeBREP(filename, shapes):
        '''
        Write a sequence of shapes or a single shape to
        a BREP file.
        '''
        cdef vector[c_OCCBase *] cshapes
        cdef Base cobj
        cdef int ret
        
        if isinstance(shapes, Base):
            shapes = (shapes,)
        
        for cobj in shapes:
            cshapes.push_back((<c_OCCBase *>cobj.thisptr))
        
        ret = writeBREP(filename, cshapes)
        if not ret:
            raise OCCError(errorMessage)
            
        return True
    
    @staticmethod
    def writeSTEP(filename, shapes):
        '''
        Write a sequence of shapes or a single shape to
        a STEP file.
        '''
        cdef vector[c_OCCBase *] cshapes
        cdef Base cobj
        cdef int ret
        
        if isinstance(shapes, Base):
            shapes = (shapes,)
        
        for cobj in shapes:
            cshapes.push_back((<c_OCCBase *>cobj.thisptr))
        
        ret = writeSTEP(filename, cshapes)
        if not ret:
            raise OCCError(errorMessage)
            
        return True
    
    @staticmethod
    def writeSTL(filename, shapes):
        '''
        Write a sequence of shapes or a single shape to
        a STL file.
        '''
        cdef vector[c_OCCBase *] cshapes
        cdef Base cobj
        cdef int ret
        
        if isinstance(shapes, Base):
            shapes = (shapes,)
        
        for cobj in shapes:
            cshapes.push_back((<c_OCCBase *>cobj.thisptr))
        
        ret = writeSTL(filename, cshapes)
        if not ret:
            raise OCCError(errorMessage)
            
        return True
    
    @staticmethod
    def writeVRML(filename, shapes):
        '''
        Write a sequence of shapes or a single shape to
        a VRML file.
        '''
        cdef vector[c_OCCBase *] cshapes
        cdef Base cobj
        cdef int ret
        
        if isinstance(shapes, Base):
            shapes = (shapes,)
        
        for cobj in shapes:
            cshapes.push_back((<c_OCCBase *>cobj.thisptr))
        
        ret = writeVRML(filename, cshapes)
        if not ret:
            raise OCCError(errorMessage)
            
        return True

    @staticmethod
    def readBREP(filename):
        '''
        Read shapes from a BREP file.
        
        A sequence of shapes are returned.
        '''
        cdef vector[c_OCCBase *] cshapes
        cdef Solid solid
        cdef Face face
        cdef Wire wire
        cdef Edge edge
        cdef Vertex vertex
        cdef int i, ret
        
        ret = readBREP(filename, cshapes)
        if not ret:
            raise OCCError(errorMessage)
            
        if cshapes.size() == 0:
            raise OCCError('Failed to import objects')
        
        res = []
        for i in range(cshapes.size()):
            shapetype = cshapes[i].shapeType()
            
            if shapetype == TopAbs_COMPSOLID or \
               shapetype == TopAbs_SOLID:
                solid = Solid.__new__(Solid, None)
                solid.thisptr = cshapes[i]
                res.append(solid)
                
            elif shapetype == TopAbs_SHELL or \
                 shapetype == TopAbs_FACE:
                face = Face.__new__(Face, None)
                face.thisptr = cshapes[i]
                res.append(face)
                
            elif shapetype == TopAbs_WIRE:
                wire = Wire.__new__(Wire, None)
                wire.thisptr = cshapes[i]
                res.append(wire)
                
            elif shapetype == TopAbs_EDGE:
                edge = Edge.__new__(Edge, None)
                edge.thisptr = cshapes[i]
                res.append(edge)
                
            elif shapetype == TopAbs_VERTEX:
                vertex = Vertex.__new__(Vertex, None)
                vertex.thisptr = cshapes[i]
                res.append(vertex)
                
        return res
    
    @staticmethod
    def readSTEP(filename):
        '''
        Read shapes from a STEP file.
        
        A sequence of shapes are returned.
        '''
        cdef vector[c_OCCBase *] cshapes
        cdef Solid solid
        cdef Face face
        cdef Wire wire
        cdef Edge edge
        cdef Vertex vertex
        cdef int i, ret
        
        ret = readSTEP(filename, cshapes)
        if not ret or cshapes.size() == 0:
            raise OCCError(errorMessage)
        
        res = []
        for i in range(cshapes.size()):
            shapetype = cshapes[i].shapeType()
            
            if shapetype == TopAbs_COMPSOLID or \
               shapetype == TopAbs_SOLID:
                solid = Solid.__new__(Solid, None)
                solid.thisptr = cshapes[i]
                res.append(solid)
                
            elif shapetype == TopAbs_SHELL or \
                 shapetype == TopAbs_FACE:
                face = Face.__new__(Face, None)
                face.thisptr = cshapes[i]
                res.append(face)
                
            elif shapetype == TopAbs_WIRE:
                wire = Wire.__new__(Wire, None)
                wire.thisptr = cshapes[i]
                res.append(wire)
                
            elif shapetype == TopAbs_EDGE:
                edge = Edge.__new__(Edge, None)
                edge.thisptr = cshapes[i]
                res.append(edge)
                
            elif shapetype == TopAbs_VERTEX:
                vertex = Vertex.__new__(Vertex, None)
                vertex.thisptr = cshapes[i]
                res.append(vertex)
                
        return res