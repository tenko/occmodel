# -*- coding: utf-8 -*-

cdef class Edge(Base):
    '''
    Edge - represent edge geometry (curve).
    '''
    cdef public Vertex start, end
    
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
        return "(start = %s, end = %s)" % (repr(self.start), repr(self.end))
    
    cpdef Edge copy(self):
        '''
        Create copy of edge
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef Edge ret = Edge.__new__(Edge, None)
        ret.thisptr = occ.copy()
        return ret
    
    cpdef tesselate(self, double factor = .1, double angle = .1):
        '''
        Tesselate edge to a tuple of points according to given
        max angle or distance factor
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef vector[vector[double]] pnts
        cdef size_t i, size
        
        pnts = occ.tesselate(factor, angle)
        
        size = pnts.size()
        if size < 2:
            raise OCCError('Failed to tesselate edge')
        
        ret = [(pnts[i][0], pnts[i][1], pnts[i][2]) for i in range(size)]
        
        return tuple(ret)
        
    cpdef createLine(self, Vertex start, Vertex end):
        '''
        Create straight line from given start and end
        points
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef int ret
        
        self.start = start
        self.end = end
        
        ret = occ.createLine(<c_OCCVertex *>start.thisptr, <c_OCCVertex *>end.thisptr)
        
        if ret != 0:
            raise OCCError('Failed to create line')
            
        return self
    
    cpdef createArc(self, Vertex start, Vertex end, center):
        '''
        Create arc from given start, end and center points
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef vector[double] cpnt
        cdef int ret
        
        self.start = start
        self.end = end
        
        cpnt.push_back(center[0])
        cpnt.push_back(center[1])
        cpnt.push_back(center[2])
        
        ret = occ.createArc(<c_OCCVertex *>start.thisptr,
                            <c_OCCVertex *>end.thisptr, cpnt)
        
        if ret != 0:
            raise OCCError('Failed to create arc')
            
        return self
        
    cpdef createArc3P(self, Vertex start, Vertex end, pnt):
        '''
        Create arc by fitting through given points
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef vector[double] cpnt
        cdef int ret
        
        self.start = start
        self.end = end
        
        cpnt.push_back(pnt[0])
        cpnt.push_back(pnt[1])
        cpnt.push_back(pnt[2])
        
        ret = occ.createArc3P(<c_OCCVertex *>start.thisptr,
                              <c_OCCVertex *>end.thisptr, cpnt)
        
        if ret != 0:
            raise OCCError('Failed to create arc')
            
        return self
    
    cpdef createCircle(self, center, normal, double radius):
        '''
        Create circle from center, normal direction and radius.
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef vector[double] ccen, cnor
        cdef int ret
        
        self.start = None
        self.end = None
        
        ccen.push_back(center[0])
        ccen.push_back(center[1])
        ccen.push_back(center[2])
        
        cnor.push_back(normal[0])
        cnor.push_back(normal[1])
        cnor.push_back(normal[2])
        
        ret = occ.createCircle(ccen, cnor, radius)
        
        if ret != 0:
            raise OCCError('Failed to create circle')
            
        return self
        
    cpdef createEllipse(self, center, normal, double rMajor, double rMinor):
        '''
        Create ellipse from center, normal direction and given
        major and minor axis.
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef vector[double] ccen, cnor
        cdef int ret
        
        self.start = None
        self.end = None
        
        ccen.push_back(center[0])
        ccen.push_back(center[1])
        ccen.push_back(center[2])
        
        cnor.push_back(normal[0])
        cnor.push_back(normal[1])
        cnor.push_back(normal[2])
        
        ret = occ.createEllipse(ccen, cnor, rMajor, rMinor)
        
        if ret != 0:
            raise OCCError('Failed to create ellipse')
            
        return self
    
    cpdef createHelix(self, double pitch, double height, double radius, double angle = 0., bint leftHanded = False):
        '''
        Create helix curve
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef int ret
        
        self.start = Vertex(0.,0.,0.)
        self.end = Vertex(0.,0.,0.)
        
        ret = occ.createHelix(<c_OCCVertex *>self.start.thisptr,
                              <c_OCCVertex *>self.end.thisptr,
                              pitch, height, radius, angle, leftHanded)
        
        if ret != 0:
            raise OCCError('Failed to create ellipse')
            
        return self
        
    cpdef createBezier(self, Vertex start = None, Vertex end = None, points = None):
        '''
        Create bezier curve from start,end and given controll
        points.
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef vector[vector[double]] cpoints
        cdef vector[double] tmp
        cdef int ret
        
        if not points:
            raise OCCError("Argument 'points' missing")
        
        for point in points:
            tmp.clear()
            tmp.push_back(point[0])
            tmp.push_back(point[1])
            tmp.push_back(point[2])
            cpoints.push_back(tmp)
        
        if start is None and end is None:
            ret = occ.createBezier(NULL, NULL, cpoints)
        else:
            self.start = start
            self.end = end
            ret = occ.createBezier(<c_OCCVertex *>start.thisptr,
                                   <c_OCCVertex *>end.thisptr, cpoints)
            
        if ret != 0:
            raise OCCError('Failed to create edge')
            
        return self

    cpdef createSpline(self, Vertex start = None, Vertex end = None,
                       points = None, tolerance = 1e-6):
        '''
        Create interpolating spline from start, end and
        given points.
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef vector[vector[double]] cpoints
        cdef vector[double] tmp
        cdef int ret
        
        if not points:
            raise OCCError("Argumrnt 'points' missing")
        
        for point in points:
            tmp.clear()
            tmp.push_back(point[0])
            tmp.push_back(point[1])
            tmp.push_back(point[2])
            cpoints.push_back(tmp)
        
        if start is None and end is None:
            ret = occ.createSpline(NULL, NULL, cpoints, tolerance)
        else:
            self.start = start
            self.end = end
            ret = occ.createSpline(<c_OCCVertex *>start.thisptr,
                                   <c_OCCVertex *>end.thisptr, cpoints, tolerance)
            
        if ret != 0:
            raise OCCError('Failed to create edge')
            
        return self

    cpdef createNURBS(self, Vertex start = None, Vertex end = None, points = None,
                      knots = None, weights = None, mults = None):
        '''
        Create NURBS curve.
        
        start - start point
        end - end point
        points - sequence of controll points
        knots - sequence of kont values
        weights - sequence of controll point weights
        mults - sequence of knot multiplicity
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        cdef vector[vector[double]] cpoints
        cdef vector[double] tmp, cknots, cweights
        cdef vector[int] cmults
        cdef int ret
        
        if not points or not knots or not weights or not mults:
            raise OCCError("Arguments missing")
        
        for point in points:
            tmp.clear()
            tmp.push_back(point[0])
            tmp.push_back(point[1])
            tmp.push_back(point[2])
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
            self.start = start
            self.end = end
            ret = occ.createNURBS(<c_OCCVertex *>start.thisptr,
                                   <c_OCCVertex *>end.thisptr, cpoints,
                                   cknots, cweights, cmults)
            
        if ret != 0:
            raise OCCError('Failed to create edge')
            
        return self
        
    cpdef double length(self):
        '''
        Return edge length
        '''
        cdef c_OCCEdge *occ = <c_OCCEdge *>self.thisptr
        return occ.length()