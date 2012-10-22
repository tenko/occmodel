# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#
cdef class Edge(Base):
    '''
    Edge - represent a single curve.
    '''
    def __init__(self):
        self.thisptr = new c_OCCEdge()
      
    def __dealloc__(self):
        cdef c_OCCEdge *tmp
        
        if self.thisptr != NULL:
            tmp = <c_OCCEdge *>self.thisptr
            del tmp
        
    def __str__(self):
        return "Edge%s" % repr(self)
    
    def __repr__(self):
        return "()"
    
    def __len__(self):
        return self.numVertices()
    
    def __iter__(self):
        return VertexIterator(self)
    
    cpdef AABBox boundingBox(self, double tolerance = 1e-12):
        '''
        Return bounding box
        '''
        if self.numVertices() == 0:
            raise OCCError('bounding box not defined')
        
        return Base.boundingBox(self, tolerance)
        
    cpdef bint isSeam(self, Face face):
        '''
        Check if edge is a seam on face
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        return occ.isSeam(<c_OCCBase *>face.thisptr)
    
    cpdef bint isDegenerated(self):
        '''
        Check if edge is degenerated e.g. collapsed etc.
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        return occ.isDegenerated()
        
    cpdef bint isClosed(self):
        '''
        Check if edge is closed
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        return occ.isClosed()
        
    cpdef Edge copy(self, bint deepCopy = False):
        '''
        Create copy of edge
        
        :param deepCopy: If true a full copy of the underlying geometry
                         is done. Defaults to False.
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef Edge ret = Edge.__new__(Edge, None)
        
        ret.thisptr = occ.copy(deepCopy)
            
        return ret
    
    cpdef Edge copyFrom(self, Edge edge, bint deepCopy = False):
        '''
        Set self from copy of edge
        
        :param edge: Edge to copy
        :param deepCopy: If true a full copy of the underlying geometry
                         is done. Defaults to False.
        '''
        cdef c_OCCEdge *tmp
        
        # remove object
        tmp = <c_OCCEdge *>self.thisptr
        del tmp
        
        # set to copy
        tmp = <c_OCCEdge *>edge.thisptr
        self.thisptr = tmp.copy(deepCopy)
        
        return self
        
    cpdef int numVertices(self):
        '''
        Return number of vertices
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        return occ.numVertices()
        
    cpdef Tesselation tesselate(self, double factor = .1, double angle = .1):
        '''
        Tesselate edge to given max angle or distance factor
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef c_OCCTesselation *tess = occ.tesselate(factor, angle)
        cdef Tesselation ret = Tesselation.__new__(Tesselation, None)
        
        if tess == NULL:
            raise OCCError(errorMessage)
        
        ret.thisptr = tess
        ret.setArrays()
        return ret
        
    cpdef createLine(self, start, end):
        '''
        Create straight line from given start and end
        points
        
        example::
            
            e1 = Edge().createLine(start = (0.,0.,0.), end = (1.,1.,0.))
        '''
        cdef Vertex vstart, vend
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef int ret
        
        if isinstance(start, Vertex):
            vstart = start
        else:
            vstart = Vertex(*start)
        
        if isinstance(end, Vertex):
            vend = end
        else:
            vend = Vertex(*end)
            
        ret = occ.createLine(<c_OCCVertex *>vstart.thisptr, <c_OCCVertex *>vend.thisptr)
        
        if not ret:
            raise OCCError(errorMessage)
            
        return self
    
    cpdef createArc(self, start, end, center):
        '''
        Create arc from given start, end and center points.
        
        example::
            
            e1 = Edge().createArc(start = (-.5,0.,0.), end = (.5,1.,0.), center = (.5,0.,0.))
        '''
        cdef Vertex vstart, vend
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef c_OCCStruct3d cpnt
        cdef int ret
        
        if isinstance(start, Vertex):
            vstart = start
        else:
            vstart = Vertex(*start)
        
        if isinstance(end, Vertex):
            vend = end
        else:
            vend = Vertex(*end)
            
        cpnt.x = center[0]
        cpnt.y = center[1]
        cpnt.z = center[2]
        
        ret = occ.createArc(<c_OCCVertex *>vstart.thisptr,
                            <c_OCCVertex *>vend.thisptr, cpnt)
        
        if not ret:
            raise OCCError(errorMessage)
            
        return self
        
    cpdef createArc3P(self, start, end, pnt):
        '''
        Create arc from start to end and fitting through
        given point.
        
        example::
            
            e1 = Edge().createArc3P(start = (1.,0.,0.), end = (-1.,0.,0.), pnt = (0.,1.,0.))
        '''
        cdef Vertex vstart, vend
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef c_OCCStruct3d cpnt
        cdef int ret
        
        if isinstance(start, Vertex):
            vstart = start
        else:
            vstart = Vertex(*start)
        
        if isinstance(end, Vertex):
            vend = end
        else:
            vend = Vertex(*end)
            
        cpnt.x = pnt[0]
        cpnt.y = pnt[1]
        cpnt.z = pnt[2]
        
        ret = occ.createArc3P(<c_OCCVertex *>vstart.thisptr,
                              <c_OCCVertex *>vend.thisptr, cpnt)
        
        if not ret:
            raise OCCError(errorMessage)
            
        return self
    
    cpdef createCircle(self, center, normal, double radius):
        '''
        Create circle from center, normal direction and radius.
        
        example::
            
            e1 = Edge().createCircle(center = (0.,.0,0.), normal = (0.,0.,1.), radius = 1.)
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef c_OCCStruct3d ccen, cnor
        cdef int ret
        
        ccen.x = center[0]
        ccen.y = center[1]
        ccen.z = center[2]
        
        cnor.x = normal[0]
        cnor.y = normal[1]
        cnor.z = normal[2]
        
        ret = occ.createCircle(ccen, cnor, radius)
        
        if not ret:
            raise OCCError(errorMessage)
            
        return self
        
    cpdef createEllipse(self, center, normal, double rMajor, double rMinor):
        '''
        Create ellipse from center, normal direction and given
        major and minor axis.
        
        example::
            
            e1 = Edge().createEllipse(center=(0.,0.,0.),normal=(0.,0.,1.), rMajor = .5, rMinor=.2)
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef c_OCCStruct3d ccen, cnor
        cdef int ret
        
        ccen.x = center[0]
        ccen.y = center[1]
        ccen.z = center[2]
        
        cnor.x = normal[0]
        cnor.y = normal[1]
        cnor.z = normal[2]
        
        ret = occ.createEllipse(ccen, cnor, rMajor, rMinor)
        
        if not ret:
            raise OCCError(errorMessage)
            
        return self
    
    cpdef createHelix(self, double pitch, double height, double radius, double angle = 0., bint leftHanded = False):
        '''
        Create helix curve.
        
        example::
            
            e1 = Edge().createHelix(pitch = .5, height = 1., radius = .25, angle = pi/5.)
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef int ret
        
        ret = occ.createHelix(pitch, height, radius, angle, leftHanded)
        
        if not ret:
            raise OCCError(errorMessage)
            
        return self
        
    cpdef createBezier(self, Vertex start = None, Vertex end = None, points = None):
        '''
        Create bezier curve.
        Optional start and end Vertex object can be given
        otherwise start and end are extracted from the
        points sequence.
        
        example::
            
            pnts = ((0.,0.,0.), (0.,1.,0.), (1.,.5,0.), (1.,0.,0.))
            e1 = Edge().createBezier(points = pnts)
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef vector[c_OCCStruct3d] cpoints
        cdef c_OCCStruct3d tmp
        cdef int ret
        
        if not points:
            raise OCCError("Argument 'points' missing")
        
        for point in points:
            tmp.x = point[0]
            tmp.y = point[1]
            tmp.z = point[2]
            cpoints.push_back(tmp)
        
        if start is None and end is None:
            ret = occ.createBezier(NULL, NULL, cpoints)
        else:
            ret = occ.createBezier(<c_OCCVertex *>start.thisptr,
                                   <c_OCCVertex *>end.thisptr, cpoints)
            
        if not ret:
            raise OCCError(errorMessage)
            
        return self

    cpdef createSpline(self, Vertex start = None, Vertex end = None,
                       points = None, tolerance = 1e-6):
        '''
        Create interpolating spline.
        
        Optional start and end Vertex object can be given
        otherwise start and end are extracted from the
        points sequence.
        
        example::
            
            pnts = ((0.,0.,0.), (0.,.5,0.), (1.,.25,0.),(1.,0.,0.))
            e1 = Edge().createSpline(points = pnts)
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef vector[c_OCCStruct3d] cpoints
        cdef c_OCCStruct3d tmp
        cdef int ret
        
        if not points:
            raise OCCError("Argument 'points' missing")
        
        for point in points:
            tmp.x = point[0]
            tmp.y = point[1]
            tmp.z = point[2]
            cpoints.push_back(tmp)
        
        if start is None and end is None:
            ret = occ.createSpline(NULL, NULL, cpoints, tolerance)
        else:
            ret = occ.createSpline(<c_OCCVertex *>start.thisptr,
                                   <c_OCCVertex *>end.thisptr, cpoints, tolerance)
            
        if not ret:
            raise OCCError(errorMessage)
            
        return self

    cpdef createNURBS(self, Vertex start = None, Vertex end = None, points = None,
                      knots = None, weights = None, mults = None):
        '''
        Create NURBS curve.
        
        :param start: optional start Vertex
        :param end: optional end Vertex
        :param points: sequence of controll points
        :param knots: sequence of kont values
        :param weights: sequence of controll point weights
        :param mults: sequence of knot multiplicity
        
        If start and end Vertex objects are not given
        the start and end point is given by the points
        sequence.
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef vector[c_OCCStruct3d] cpoints
        cdef c_OCCStruct3d tmp
        cdef vector[double] cknots, cweights
        cdef vector[int] cmults
        cdef int ret
        
        if not points or not knots or not weights or not mults:
            raise OCCError("Arguments missing")
        
        for point in points:
            tmp.x = point[0]
            tmp.y = point[1]
            tmp.z = point[2]
            cpoints.push_back(tmp)
        
        for knot in knots:
            cknots.push_back(knot)
        
        for weight in weights:
            cweights.push_back(weight)
        
        for mult in mults:
            cmults.push_back(mult)
            
        if start is None and end is None:
            ret = occ.createNURBS(NULL, NULL, cpoints, cknots, cweights, cmults)
        else:
            ret = occ.createNURBS(<c_OCCVertex *>start.thisptr,
                                   <c_OCCVertex *>end.thisptr, cpoints,
                                   cknots, cweights, cmults)
            
        if not ret:
            raise OCCError(errorMessage)
            
        return self
        
    cpdef double length(self):
        '''
        Return edge length
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        
        if self.isNull() or not self.isValid():
            raise OCCError('length not defined for object')
            
        return occ.length()

cdef class EdgeIterator:
    '''
    Iterator of edges
    '''
    cdef c_OCCEdgeIterator *thisptr
    cdef set seen
    cdef bint includeAll
    
    def __init__(self, Base arg, bint includeAll = False):
        self.thisptr = new c_OCCEdgeIterator(<c_OCCBase *>arg.thisptr)
        self.includeAll = includeAll
        self.seen = set()
        
    def __dealloc__(self):
        del self.thisptr
            
    def __str__(self):
        return 'EdgeIterator%s' % self.__repr__()
    
    def __repr__(self):
        return '()'
    
    def __iter__(self):
        return self
        
    def __next__(self):
        cdef c_OCCEdge *nxt
        cdef int hash
        
        while True:
            nxt = self.thisptr.next()
            if nxt == NULL:
                raise StopIteration()
            
            if self.includeAll:
                break
            else:
                # check for duplicate (same edge different orientation)
                hash = (<c_OCCBase *>nxt).hashCode()
                if hash in self.seen:
                    continue
                else:
                    self.seen.add(hash)
                    break
        
        cdef Edge ret = Edge.__new__(Edge)
        ret.thisptr = nxt
        return ret
    
    cpdef reset(self):
        '''Restart the iteration'''
        self.thisptr.reset()