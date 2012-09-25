# -*- coding: utf-8 -*-

INSCRIBE = 'inscribe'
CIRCUMSCRIBE = 'circumscribe'
    
cdef class Wire(Base):
    '''
    Wire - represent wire geometry (composite curve forming face border).
    '''
    def __init__(self):
        self.thisptr = new c_OCCWire()
      
    def __dealloc__(self):
        cdef c_OCCWire *tmp
        
        if self.thisptr != NULL:
            tmp = <c_OCCWire *>self.thisptr
            del tmp
        
    def __str__(self):
        return "Wire%s" % repr(self)
    
    def __repr__(self):
        return "()"
    
    def __len__(self):
        return self.numEdges()
    
    def __iter__(self):
        return EdgeIterator(self)
        
    cpdef Wire copy(self):
        '''
        Create copy of wire
        '''
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
        cdef Wire ret = Wire.__new__(Wire, None)
        ret.thisptr = occ.copy()
        return ret
    
    cpdef int numVertices(self):
        '''
        Return number of vertices
        '''
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
        return occ.numVertices()
    
    cpdef int numEdges(self):
        '''
        Return number of edges
        '''
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
        return occ.numEdges()
        
    cpdef createWire(self, edges):
        '''
        Create wire by connecting edges.
        '''
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
        cdef vector[c_OCCEdge *] cedges
        cdef Edge edge
        cdef int ret
        
        if isinstance(edges, Edge):
            edges = (edges,)
            
        for edge in edges:
            cedges.push_back((<c_OCCEdge *>edge.thisptr))
        
        ret = occ.createWire(cedges)
            
        if ret != 0:
            raise OCCError('Failed to loft wires')
            
        return self
        
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
         
    cpdef createRectangle(self, double width = 1., double height = 1., double radius = 0.):
        '''
        Create planar rectangle in the xy plan.
        
        The rectangle is centered at 0,0 with given
        width, height and optional corner radius.
        '''
        hw, hh = .5*width, .5*height
        
        # types
        NORMAL,ROUNDED,HROUNDED,VROUNDED,CIRCLE = range(5)
        
        rtyp = NORMAL
        if radius > EPSILON:
            rtyp = ROUNDED
            if radius > hh:
                raise OCCError('Height to small for radius')
            elif hh - radius < EPSILON or hh - radius == 0.:
                rtyp = VROUNDED
                radius = hh
            
            if radius > hw:
                raise OCCError('Width to small for radius')
            elif hw - radius < EPSILON:
                if rtyp == VROUNDED:
                    rtyp = CIRCLE
                else:
                    rtyp = HROUNDED
                    radius = hw
        else:
            radius = 0.
        
        if rtyp == NORMAL:
            p1 = Vertex(-hw,-hh,0.)
            p2 = Vertex(+hw,-hh,0.)
            p3 = Vertex(+hw,+hh,0.)
            p4 = Vertex(-hw,+hh,0.)
            e1 = Edge().createLine(p1,p2)
            e2 = Edge().createLine(p2,p3)
            e3 = Edge().createLine(p3,p4)
            e4 = Edge().createLine(p4,p1)
            self.createWire((e1,e2,e3,e4))
            
        elif rtyp == CIRCLE:
            e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = radius)
            self.createWire(e1)
        
        elif rtyp == VROUNDED:
            r = radius
            p1 = Vertex(-hw + r,-hh,0.)
            p2 = Vertex(+hw - r,-hh,0.)
            p3 = Vertex(+hw - r,+hh,0.)
            p4 = Vertex(-hw + r,+hh,0.)
            
            a1 = (hw,0.,0.)
            a2 = (-hw,0.,0.)
            
            e1 = Edge().createLine(p1,p2)
            e2 = Edge().createArc3P(p2,p3,a1)
            e3 = Edge().createLine(p3,p4)
            e4 = Edge().createArc3P(p4,p1,a2)
            self.createWire((e1,e2,e3,e4))
        
        elif rtyp == HROUNDED:
            r = radius
            p1 = Vertex(-hw,-hh + r,0.)
            p2 = Vertex(+hw,-hh + r,0.)
            p3 = Vertex(+hw,+hh - r,0.)
            p4 = Vertex(-hw,+hh - r,0.)
            
            a1 = (0.,-hh,0.)
            a2 = (0.,+hh,0.)
            
            e1 = Edge().createArc3P(p1,p2,a1)
            e2 = Edge().createLine(p2,p3)
            e3 = Edge().createArc3P(p3,p4,a2)
            e4 = Edge().createLine(p4,p1)
            
            self.createWire((e1,e2,e3,e4))
            
        elif rtyp == ROUNDED:
            r = radius
            p1 = Vertex(-hw + r,-hh + 0,0.)
            p2 = Vertex(+hw - r,-hh + 0,0.)
            p3 = Vertex(+hw + 0,-hh + r,0.)
            p4 = Vertex(+hw + 0,+hh - r,0.)
            p5 = Vertex(+hw - r,+hh + 0,0.)
            p6 = Vertex(-hw + r,+hh + 0,0.)
            p7 = Vertex(-hw + 0,+hh - r,0.)
            p8 = Vertex(-hw + 0,-hh + r,0.)
            
            c1 = (-hw + r,-hh + r,0.)
            c2 = (+hw - r,-hh + r,0.)
            c3 = (+hw - r,+hh - r,0.)
            c4 = (-hw + r,+hh - r,0.)
            
            e1 = Edge().createArc(p8,p1,c1)
            e2 = Edge().createLine(p1,p2)
            e3 = Edge().createArc(p2,p3,c2)
            e4 = Edge().createLine(p3,p4)
            e5 = Edge().createArc(p4,p5,c3)
            e6 = Edge().createLine(p5,p6)
            e7 = Edge().createArc(p6,p7,c4)
            e8 = Edge().createLine(p7,p8)
            
            self.createWire((e1,e2,e3,e4,e5,e6,e7,e8))
        else:
            raise OCCError('Unknown type %d' % rtyp)
            
        return self
    
    cpdef createPolygon(self, points, bint close = True):
        '''
        Create a polygon from given points.
        
        Note: The polygon is closed automatic.
        '''
        edges = [Edge().createLine(Vertex(*points[0]),Vertex(*points[1]))]
        for point in points[2:]:
            edge = Edge().createLine(edges[-1].end,Vertex(*point))
            edges.append(edge)
        # close
        if close:
            edge = Edge().createLine(edges[-1].end,edges[0].start)
            edges.append(edge)
            
        self.createWire(edges)
        return self
        

    cpdef createRegularPolygon(self, double radius = 1., int sides = 6, mode = INSCRIBE):
        '''
        Create a planar regular polygon in the xy plane centered at (0,0).
        
        The polygon can either be inscribed or circumscribe the circle by setting
        the mode argument.
        '''
        if sides < 3 or radius < 1e-16:
            raise OCCError('Arguments not consistent')
            
        points = []
        delta = 2.*M_PI/sides
        
        r = radius
        if mode == CIRCUMSCRIBE:
            r /= cos(.5*delta)
        elif mode != INSCRIBE:
            raise OCCError('Unknown mode %s' % mode)
        
        angle = .5*delta
        for i in range(sides):
            x = cos(angle)*r
            if abs(x - radius) < SQRT_EPSILON:
                x = copysign(radius, x)
                
            y = sin(angle)*r
            if abs(y - radius) < SQRT_EPSILON:
                y = copysign(radius, y)
                
            points.append((x, y))
            angle += delta
        
        self.createPolygon(points)
        return self
        
    cpdef double length(self):
        '''
        Return wire length
        '''
        cdef c_OCCWire *occ = <c_OCCWire *>self.thisptr
        return occ.length()

cdef class WireIterator:
    '''
    Iterator of wires
    '''
    cdef c_OCCWireIterator *thisptr
    
    def __init__(self, Base arg):
        self.thisptr = new c_OCCWireIterator(<c_OCCBase *>arg.thisptr)
      
    def __dealloc__(self):
        del self.thisptr
            
    def __str__(self):
        return 'WireIterator%s' % self.__repr__()
    
    def __repr__(self):
        return '()'
    
    def __iter__(self):
        return self
        
    def __next__(self):
        cdef c_OCCWire *nxt = self.thisptr.next()
        if nxt == NULL:
            raise StopIteration()
        
        cdef Wire ret = Wire.__new__(Wire)
        ret.thisptr = nxt
        return ret