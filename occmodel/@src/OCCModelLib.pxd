cdef extern from *:
    ctypedef char* const_char_ptr "char*"

cdef extern from "<vector>" namespace "std":
    cdef cppclass vector[T]:
       vector()
       void clear()
       void push_back(T&)
       size_t size()
       T& operator[](size_t)

cdef extern from "OCCModel.h":
    cdef cppclass c_OCCMesh "OCCMesh":
        vector[vector[double]] vertices
        vector[vector[double]] normals
        vector[vector[int]] triangles
        c_OCCMesh()
    
    cdef cppclass c_OCCBase "OCCBase":
        bint isEqual(c_OCCBase *other)
        bint isNull()
        bint isValid()
        int transform(vector[double] mat)
        int translate(vector[double] delta)
        int rotate(vector[double] p1, vector[double] p2, double angle)
        int scale(vector[double] pnt, double scale)
        int mirror(vector[double] pnt, vector[double] nor)
        vector[double] boundingBox(double tolerance)
        int findPlane(double *origin, double *normal, double tolerance)
        
    cdef cppclass c_OCCVertex "OCCVertex":
        c_OCCVertex(double x, double y, double z)
        double x()
        double y()
        double z()
        
    cdef cppclass c_OCCEdge "OCCEdge":
        c_OCCEdge()
        c_OCCEdge *copy()
        vector[vector[double]] tesselate(double factor, double angle)
        int createLine(c_OCCVertex *v1, c_OCCVertex *v2)
        int createArc(c_OCCVertex *start, c_OCCVertex *end, vector[double] center)
        int createArc3P(c_OCCVertex *start, c_OCCVertex *end, vector[double] pnt)
        int createCircle(vector[double] center, vector[double] normal, double radius)
        int createEllipse(vector[double] pnt, vector[double] nor, double rMajor, double rMinor)
        int createHelix(c_OCCVertex *start, c_OCCVertex *end, double pitch, double height, double radius, double angle, bint leftHanded)
        int createBezier(c_OCCVertex *start, c_OCCVertex *end, vector[vector[double]] points)
        int createSpline(c_OCCVertex *start, c_OCCVertex *end, vector[vector[double]] points, double tolerance)
        int createNURBS(c_OCCVertex *start, c_OCCVertex *end, vector[vector[double]] points,
                        vector[double] knots, vector[double] weights, vector[int] mult)
        double length()
    
    cdef cppclass c_OCCWire "OCCWire":
        c_OCCWire()
        c_OCCWire *copy()
        vector[vector[double]] tesselate(double factor, double angle)
        int createWire(vector[c_OCCEdge *] edges)
        double length()
        
    cdef cppclass c_OCCFace "OCCFace":
        c_OCCFace()
        c_OCCFace *copy()
        int createFace(c_OCCWire *wire)
        int createConstrained(vector[c_OCCEdge *] edges, vector[vector[double]] points)
        double area()
        vector[double] inertia()
        vector[double] centreOfMass()
        int createPolygonal(vector[vector[double]] points)
        int extrude(c_OCCEdge *edge, vector[double] p1, vector[double] p2)
        int revolve(c_OCCEdge *edge, vector[double] p1, vector[double] p2, double angle)
        c_OCCMesh *createMesh(double factor, double angle)
    
    ctypedef int (*filter_func)(void *user_data, double *near, double *far)
    
    cdef cppclass c_OCCSolid "OCCSolid":
        c_OCCSolid()
        int createSolid(vector[c_OCCFace *] faces, double tolerance)
        double area()
        double volume()
        vector[double] inertia()
        vector[double] centreOfMass()
        c_OCCSolid *copy()
        c_OCCMesh *createMesh(double factor, double angle)
        int addSolids(vector[c_OCCSolid *] solids)
        int createSphere(vector[double] center, double radius)
        int createCylinder(vector[double] p1, vector[double] p2, double radius)
        int createTorus(vector[double] p1, vector[double] p2, double radius1, double radius2)
        int createCone(vector[double] p1, vector[double] p2, double radius1, double radius2)
        int createBox(vector[double] p1, vector[double] p2)
        int extrude(c_OCCFace *face, vector[double] p1, vector[double] p2)
        int revolve(c_OCCFace *face, vector[double] p1, vector[double] p2, double angle)
        int loft(vector[c_OCCBase *] profiles, bint ruled, double tolerance)
        int sweep(c_OCCWire *spine, vector[c_OCCBase *] profiles, int cornerMode)
        int booleanUnion(c_OCCSolid *tool)
        int booleanDifference(c_OCCSolid *tool)
        int booleanIntersection(c_OCCSolid *tool)
        int fillet(double radius, filter_func userfunc, void *userdata)
        int chamfer(double distance, filter_func userfunc, void *userdata)
        int shell(double offset, filter_func userfunc, void *userdata)
        c_OCCFace *section(vector[double] pnt, vector[double] nor)
        int writeBREP(char *filename)
        int readBREP(char *filename)
        int writeSTEP(char *filename)
        int readSTEP(char *filename)
        int writeSTL(char *filename, bint asciiMode)
        void heal(double tolerance, bint fixdegenerated,
                  bint fixsmalledges, bint fixspotstripfaces, 
                  bint sewfaces, bint makesolids)        
        