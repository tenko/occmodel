// Gmsh - Copyright (C) 1997-2011 C. Geuzaine, J.-F. Remacle
//
// See the LICENSE.txt file for license information. Please report all
// bugs and problems to <gmsh@geuz.org>.

#include "OCCIncludes.h"
#include <vector>

typedef std::vector<float> FVec;
typedef std::vector<double> DVec;
typedef std::vector<int> IVec;

class OCCMesh {
    public:
        std::vector<DVec> normals;
        std::vector<DVec> vertices;
        std::vector<IVec> triangles;
        OCCMesh() { ; }
};

class OCCVertex { 
    public:
        TopoDS_Vertex vertex;
        double _x, _y, _z;
        OCCVertex() { ; }
        OCCVertex(double x, double y, double z) {
            _x = x; _y = y; _z = z;
            gp_Pnt aPnt;
            aPnt = gp_Pnt(x, y, z);
            BRepBuilderAPI_MakeVertex mkVertex(aPnt);
            vertex = mkVertex.Vertex();
        }
        double x() const { return _x; }
        double y() const { return _y; }
        double z() const { return _z; }
        void * getNativePtr() const { return (void*)&vertex; }
        TopoDS_Vertex getShape() { return vertex; }
};

class OCCEdge {
    public:
        TopoDS_Edge edge;
        OCCEdge() { ; }
        OCCEdge *copy();
        std::vector<DVec> tesselate(double factor, double angle);
        int translate(DVec delta);
        int rotate(DVec p1, DVec p2, double angle);
        int scale(DVec pnt, double scale);
        int mirror(DVec pnt, DVec nor);
        int createLine(OCCVertex *start, OCCVertex *end);
        int createArc(OCCVertex *start, OCCVertex *end, DVec center);
        int createArc3P(OCCVertex *start, OCCVertex *end, DVec pnt);
        int createCircle(DVec center, DVec normal, double radius);
        int createEllipse(DVec pnt, DVec nor, double rMajor, double rMinor);
        int createHelix(OCCVertex *start, OCCVertex *end, double pitch,
                        double height, double radius, double angle, bool leftHanded);
        int createBezier(OCCVertex *start, OCCVertex *end, std::vector<DVec> points);
        int createSpline(OCCVertex *start, OCCVertex *end, std::vector<DVec> points,
                         double tolerance);
        int createNURBS(OCCVertex *start, OCCVertex *end, std::vector<DVec> points,
                        DVec knots, DVec weights, IVec mult);
        double length();
        DVec boundingBox();
        void *getNativePtr() const { return (void*)&edge; }
        TopoDS_Edge getShape() { return edge; }
};

/*
class OCCWire {
    public:
        TopoDS_Wire wire;
        OCCWire() { ; }
        OCCWire *copy();
        int createWire(std::vector<OCCEdge *> edges);
        double length();
        DVec boundingBox();
        void *getNativePtr() const { return (void*)&wire; }
        TopoDS_Wire getShape() { return wire; }
};
*/

class OCCFace {
    public:
        TopoDS_Face face;
        OCCFace() { ; }
        OCCFace *copy();
        int createFace(std::vector<OCCEdge *> edges, std::vector<DVec> points);
        DVec boundingBox();
        double area();
        DVec inertia();
        DVec centreOfMass();
        std::vector<DVec> tesselate(double factor, double angle);
        int translate(DVec delta);
        int rotate(DVec p1, DVec p2, double angle);
        int scale(DVec pnt, double scale);
        int mirror(DVec pnt, DVec nor);
        int createPolygonal(std::vector<DVec> points);
        int extrude(OCCEdge *edge, DVec p1, DVec p2);
        int revolve(OCCEdge *edge, DVec p1, DVec p2, double angle);
        OCCMesh *createMesh(double defle, double angle);
        void *getNativePtr() const { return (void*)&face; }
        TopoDS_Face getShape() { return face; }
};

typedef int (*filter_func)(void *user_data, double *near, double *far);

class OCCSolid {
    public:
        TopoDS_Shape solid;
        OCCSolid() { ; }
        int createSolid(std::vector<OCCFace *> faces, double tolerance);
        DVec boundingBox();
        double area();
        double volume();
        DVec inertia();
        DVec centreOfMass();
        OCCSolid *copy();
        OCCMesh *createMesh(double defle, double angle);
        int translate(DVec delta);
        int rotate(DVec p1, DVec p2, double angle);
        int scale(DVec pnt, double scale);
        int mirror(DVec pnt, DVec nor);
        int addSolids(std::vector<OCCSolid *> solids);
        int createSphere(DVec center, double radius);
        int createCylinder(DVec p1, DVec p2, double radius);
        int createTorus(DVec p1, DVec p2, double radius1, double radius2);
        int createCone(DVec p1, DVec p2, double radius1, double radius2);
        int createBox(DVec p1, DVec p2);
        int extrude(OCCFace *face, DVec p1, DVec p2);
        int revolve(OCCFace *face, DVec p1, DVec p2, double angle);
        int loft(std::vector< std::vector<OCCEdge> > wires, bool ruled);
        int pipe(OCCFace *face, std::vector<OCCEdge *> edges);
        int booleanUnion(OCCSolid *tool);
        int booleanDifference(OCCSolid *tool);
        int booleanIntersection(OCCSolid *tool);
        int fillet(double radius, filter_func userfunc, void *userdata);
        int chamfer(double distance, filter_func userfunc, void *userdata);
        int shell(double offset, filter_func userfunc, void *userdata);
        OCCFace *section(DVec pnt, DVec nor);
        int writeBREP(const char *);  
        int readBREP(const char *);  
        int writeSTEP(const char *);
        int readSTEP(const char *fn);
        int writeSTL(const char *, bool asciiMode);
        void heal(double tolerance, bool fixdegenerated,
                  bool fixsmalledges, bool fixspotstripfaces, 
                  bool sewfaces, bool makesolids);
        void *getNativePtr() const { return (void*)&solid; }
        TopoDS_Shape getShape() { return solid; }
};

int extractFaceMesh(TopoDS_Face face, OCCMesh *mesh);
void connectEdges (std::vector<TopoDS_Edge>& edges, std::vector<TopoDS_Wire>& wires);