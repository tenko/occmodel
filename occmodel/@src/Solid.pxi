# -*- coding: utf-8 -*-

cdef int py_filter_func(void *data, double *near, double *far):
    return (<object>data)((near[0], near[1], near[2]),
                          (far[0], far[1], far[2]))
    
cdef class Solid(Base):
    '''
    Geometry represention solid objects or
    compund solid.
    '''
    def __init__(self):
        self.thisptr = new c_OCCSolid()
      
    def __dealloc__(self):
        cdef c_OCCSolid *tmp
        
        if self.thisptr != NULL:
            tmp = <c_OCCSolid *>self.thisptr
            del tmp
    
    def __str__(self):
        return "Solid%s" % repr(self)
    
    def __repr__(self):
        return "()"
    
    cpdef Solid copy(self):
        '''
        Create copy of solid
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Solid ret = Solid.__new__(Solid, None)
        ret.thisptr = occ.copy()
        return ret
        
    cpdef Mesh createMesh(self, double factor = .01, double angle = .25):
        '''
        Create triangle mesh of solid.
        
        factor - deflection from true position
        angle - max angle
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef c_OCCMesh *mesh = occ.createMesh(factor, angle)
        cdef Mesh ret = Mesh.__new__(Mesh, None)
        
        if mesh == NULL:
            raise OCCError('Failed to create mesh')
        
        ret.thisptr = mesh
        return ret
        
    cpdef createSolid(self, faces, double tolerance = 1e-6):
        '''
        Create general solid from sequence of faces
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Face face
        cdef vector[c_OCCFace *] cfaces
        cdef int ret
        
        for face in faces:
            cfaces.push_back(<c_OCCFace *>face.thisptr)
        
        ret = occ.createSolid(cfaces, tolerance)
        if ret != 0:
            raise OCCError('Failed to sew faces')
            
        return self
        
    cpdef addSolids(self, solids):
        '''
        Create compund solid from sequence
        of solid objects.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Solid solid
        cdef vector[c_OCCSolid *] csolids
        cdef int ret
        
        if isinstance(solids, Solid):
            solid = solids
            csolids.push_back(<c_OCCSolid *>solid.thisptr)
        else:
            for solid in solids:
                csolids.push_back(<c_OCCSolid *>solid.thisptr)
        
        ret = occ.addSolids(csolids)
        if ret != 0:
            raise OCCError('Failed to add solids')
            
        return self
        
    cpdef createSphere(self, center, double radius):
        '''
        Create sphere from center point and
        radius.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cen
        cdef int ret
        
        cen.push_back(center[0])
        cen.push_back(center[1])
        cen.push_back(center[2])
        
        ret = occ.createSphere(cen, radius)
        if ret != 0:
            raise OCCError('Failed to create solid')
            
        return self

    cpdef createCylinder(self, p1, p2, double radius):
        '''
        Create cylinder
        
        p1 - axis start
        p2 - axis end
        radius - cylinder radius
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.createCylinder(cp1, cp2, radius)
        if ret != 0:
            raise OCCError('Failed to create solid')
            
        return self

    cpdef createTorus(self, p1, p2, double radius1, double radius2):
        '''
        Create torus
        
        p1 - axis start
        p2 - axis end
        radius1 - inner radius
        radius2 - outer radius
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.createTorus(cp1, cp2, radius1, radius2)
        if ret != 0:
            raise OCCError('Failed to create solid')
            
        return self
    
    cpdef createCone(self, p1, p2, double radius1, double radius2):
        '''
        Crate cone
        
        p1 - axis start
        p2 - axis end
        radius1 - radius at start
        radius2 - radius at end
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.createCone(cp1, cp2, radius1, radius2)
        if ret != 0:
            raise OCCError('Failed to create solid')
            
        return self
    
    cpdef createBox(self, p1, p2):
        '''
        Crate box from points defining diagonal.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.createBox(cp1, cp2)
        if ret != 0:
            raise OCCError('Failed to create solid')
            
        return self
        
    cpdef area(self):
        '''
        Return solid area
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        return occ.area()
    
    cpdef volume(self):
        '''
        Return solid volume
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        return occ.volume()
    
    cpdef inertia(self):
        '''
        return intertia of solid with respect
        to center of gravity.
        
        Return Ixx, Iyy, Izz, Ixy, Ixz, Iyz
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] res = occ.inertia()
        return res[0],res[1],res[2],res[3],res[4],res[5]
        
    cpdef centreOfMass(self):
        '''
        return center of mass of solid.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cg = occ.centreOfMass()
        return cg[0],cg[1],cg[2]
        
    cpdef extrude(self, Face face, p1, p2):
        '''
        Create solid by extruding face from
        p1 to p2.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.extrude(<c_OCCFace *>face.thisptr, cp1, cp2)
        if ret != 0:
            raise OCCError('Failed to create solid')
            
        return self
    
    cpdef revolve(self, Face face, p1, p2, double angle):
        '''
        Create solid by revolving face
        
        p1 - start of axis
        p2 - end of axis
        angle - revolve angle
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.revolve(<c_OCCFace *>face.thisptr, cp1, cp2, angle)
        if ret != 0:
            raise OCCError('Failed to create solid')
            
        return self
        
    cpdef loft(self, profiles, bint ruled = True, double tolerance = 1e-6):
        '''
        Crate solid by lofting through sequence
        of wires or closed edges.
        
        ruled - smooth or rules faces
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[c_OCCBase *] cprofiles
        cdef Base cobj
        cdef int ret
        
        ref = []
        for obj in profiles:
            if isinstance(obj, Edge):
                obj = Wire().createWire((obj,))
                # keep reference to temporary object
                ref.append(obj)
            elif not isinstance(obj, (Wire, Vertex)):
                raise OCCError('Expected wire, edge or vertex')
            cobj = obj
            cprofiles.push_back((<c_OCCBase *>cobj.thisptr))
        
        ret = occ.loft(cprofiles, ruled, tolerance)
        
        if ret != 0:
            raise OCCError('Failed to loft profiles')
            
        return self
    
    cpdef pipe(self, Face face, path):
        '''
        Create pipe by extruding face allong
        wire or edge.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Wire wire
        cdef int ret
        
        if isinstance(path, Edge):
            wire = Wire().createWire((path,))
        else:
            wire = path
                
        ret = occ.pipe(<c_OCCFace *>face.thisptr, <c_OCCWire *>wire.thisptr)
            
        if ret != 0:
            raise OCCError('Failed to make pipe')
            
        return self
    
    def cut(self, tool):
        '''
        Cut solid with given object.
        
        Multiple objects are supported.
        
        Planar edges, wires and planes are extrude in the
        planar direction to cut through the solid.
        '''
        if not isinstance(tool, Solid):
            if not isinstance(tool, (tuple,list,set)):
                args = tool,
            else:
                args = tool
            
            solids = []
            origin = Point()
            normal = Vector()
            bbox = self.boundingBox()
            
            def translate(obj):
                if not obj.hasPlane(origin, normal):
                        raise OCCError('Object not planar')
                    
                plane = Plane().fromNormal(origin, normal)
                dist = plane.distanceTo(bbox.near)
                
                # distance below plane
                start = plane.origin
                if dist < 0.:
                    # we are above : move object
                    dist *= 1.25
                
                    dvec = dist * plane.zaxis
                    start += dvec
                    obj.translate(dvec)
                
                # distance above plan
                dist = plane.distanceTo(bbox.far)
                if dist < 0.:
                    dist *= .75
                else:
                    dist *= 1.25
                
                # calculate end point of extrusion
                end = plane.origin + dist*plane.zaxis
                
                return start, end
                    
            for arg in args:
                if isinstance(arg, Edge):
                    edge = arg.copy()
                    start, end = translate(edge)
                    wire = Wire().createWire(edge)
                    face = Face().createFace(wire)
                    solid = Solid().extrude(face, start, end)
                
                elif isinstance(arg, Wire):
                    wire = arg.copy()
                    start, end = translate(wire)
                    face = Face().createFace(wire)
                    solid = Solid().extrude(face, start, end)
                
                elif isinstance(arg, Face):
                    face = arg.copy()
                    start, end = translate(face)
                    solid = Solid().extrude(face, start, end)
                    
                elif isinstance(arg, Solid):
                    solid = arg
                
                else:
                    raise OCCError('unknown object type %s' % arg)
                    
                # todo: check if bounding boxes overlap
                solids.append(solid)
                
            if not solids:
                raise OCCError('No objects created')
            
            # create compound of solid objects
            tool = Solid().addSolids(solids)
            
        return Solid.booleanDifference(self, tool)
        
    cpdef booleanUnion(self, arg):
        '''
        Create boolean union inplace.
        
        Multiple objects are supported.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Solid tool
        
        if not isinstance(arg, Solid):
            # create compound of solid objects
            tool = Solid().addSolids(arg)
        else:
            tool = arg
            
        cdef int ret = occ.booleanUnion(<c_OCCSolid *>tool.thisptr)
        if ret != 0:
            raise OCCError('Failed to create boolean union')
        
        return self
        
    cpdef booleanDifference(self, arg):
        '''
        Create boolean difference inplace.
        
        Multiple objects are supported.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Solid tool
        
        if not isinstance(arg, Solid):
            # create compound of solid objects
            tool = Solid().addSolids(arg)
        else:
            tool = arg
            
        cdef int ret = occ.booleanDifference(<c_OCCSolid *>tool.thisptr)
        if ret != 0:
            raise OCCError('Failed to create boolean difference')
        
        return self
        
    cpdef booleanIntersection(self, arg):
        '''
        Create boolean intersection inplace.
        
        Multiple objects are supported.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        
        cdef Solid tool
        
        if not isinstance(arg, Solid):
            # create compound of solid objects
            tool = Solid().addSolids(arg)
        else:
            tool = arg
            
        cdef int ret = occ.booleanIntersection(<c_OCCSolid *>tool.thisptr)
        if ret != 0:
            raise OCCError('Failed to create boolean intersection')
        
        return self
        
    cpdef fillet(self, double radius, edgefilter = None):
        '''
        Fillet edges inplace.
        
        :radius: fillet radius
        :edgefilter: optional function taking argument of edge
                     near, far and return edge selection status (boolean)
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef int ret = occ.fillet(radius, py_filter_func, <void *>edgefilter)
        if ret != 0:
            raise OCCError('Failed to create fillet')
        
        return self
        
    cpdef chamfer(self, double distance, edgefilter = None):
        '''
        Chamfer edges inplace.
        
        :distance: chamfer distance
        :edgefilter: optional function taking argument of edge
                     near, far and return edge selection status (boolean)
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef int ret = occ.chamfer(distance, py_filter_func, <void *>edgefilter)
        if ret != 0:
            raise OCCError('Failed to create chamfer')
        
        return self
        
    cpdef shell(self, double offset, facefilter = None):
        '''
        Apply shell operation no solid.
        
        :offset: shell offset distance
        :facefilter: function taking argument of face
                     near, far and return face selection status (boolean)
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef int ret = occ.shell(offset, py_filter_func, <void *>facefilter)
        if ret != 0:
            raise OCCError('Failed to create chamfer')
        
        return self
    
    cpdef section(self, Plane plane):
        '''
        Apply section operation between solid and plane.
        
        plane - section plane
        
        Result returned as a face.
        '''
        cdef Face ret = Face.__new__(Face, None)
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cpnt, cnor
        
        cpnt.push_back(plane.origin.x)
        cpnt.push_back(plane.origin.y)
        cpnt.push_back(plane.origin.z)
        
        cnor.push_back(plane.zaxis.x)
        cnor.push_back(plane.zaxis.y)
        cnor.push_back(plane.zaxis.z)
        
        ret.thisptr = occ.section(cpnt, cnor)
        if ret.thisptr == NULL:
            raise OCCError('Failed to create section')
            
        return ret
        
    cpdef writeSTEP(self, char *filename):
        '''
        Write solid to STEP file.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef int ret = occ.writeSTEP(filename)
        if ret != 0:
            raise OCCError('Failed to write to file')
    
    cpdef readSTEP(self, char *filename):
        '''
        Read geometry from STEP file.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef int ret = occ.readSTEP(filename)
        if ret != 0:
            raise OCCError('Failed to read from STEP file')
            
    cpdef writeBREP(self, char *filename):
        '''
        Write solid to BREP file.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef int ret = occ.writeBREP(filename)
        if ret != 0:
            raise OCCError('Failed to write to file')
    
    cpdef readBREP(self, char *filename):
        '''
        Read geometry from BREP file.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef int ret = occ.readBREP(filename)
        if ret != 0:
            raise OCCError('Failed to read from BREP file')
            
    cpdef writeSTL(self, char *filename, bint asciiMode = False):
        '''
        Write solid to STL file.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef int ret = occ.writeSTL(filename, asciiMode)
        if ret != 0:
            raise OCCError('Failed to write to file')
    
    cpdef heal(self, double tolerance = 0., bint fixdegenerated = True,
                     bint fixsmalledges = True, bint fixspotstripfaces = True, 
                     bint sewfaces = False, bint makesolids = False):
        '''
        Possible heal geometry
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        occ.heal(tolerance, fixdegenerated, fixsmalledges,
                 fixspotstripfaces, sewfaces, makesolids)