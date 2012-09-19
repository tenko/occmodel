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

class OCCBase {
    public:
        int transform(DVec mat);
        int translate(DVec delta);
        int rotate(DVec p1, DVec p2, double angle);
        int scale(DVec pnt, double scale);
        int mirror(DVec pnt, DVec nor);
        DVec boundingBox(double tolerance);
        int findPlane(double *origin, double *normal, double tolerance);
        bool isEqual(OCCBase *other) {
            if (this->getShape().IsEqual(other->getShape()))
                return true;
            return false;
        }
        bool isNull() {
            return this->getShape().IsNull() ? true : false;
        }
        bool isValid() {
            if (this->getShape().IsNull())
                return false;
            BRepCheck_Analyzer aChecker(this->getShape());
            return aChecker.IsValid() ? true : false;
        }
        virtual TopoDS_Shape getShape() { return TopoDS_Shape(); }
        virtual void setShape(TopoDS_Shape shape) { ; }
};

class OCCVertex : public OCCBase { 
    public:
        TopoDS_Vertex vertex;
        OCCVertex() { ; }
        OCCVertex(double x, double y, double z) {
            gp_Pnt aPnt;
            aPnt = gp_Pnt(x, y, z);
            BRepBuilderAPI_MakeVertex mkVertex(aPnt);
            this->setShape(mkVertex.Vertex());
        }
        double x() const { 
            gp_Pnt pnt = BRep_Tool::Pnt(vertex);
            return pnt.X();
        }
        double y() const { 
            gp_Pnt pnt = BRep_Tool::Pnt(vertex);
            return pnt.Y();
        }
        double z() const { 
            gp_Pnt pnt = BRep_Tool::Pnt(vertex);
            return pnt.Z();
        }
        TopoDS_Shape getShape() { return vertex; }
        void setShape(TopoDS_Shape shape) { vertex = TopoDS::Vertex(shape); }
};

class OCCEdge : public OCCBase {
    public:
        TopoDS_Edge edge;
        OCCEdge() { ; }
        OCCEdge *copy();
        std::vector<DVec> tesselate(double factor, double angle);
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
        TopoDS_Shape getShape() { return edge; }
        void setShape(TopoDS_Shape shape) { edge = TopoDS::Edge(shape); }
};

class OCCWire : public OCCBase {
    public:
        TopoDS_Wire wire;
        OCCWire() { ; }
        OCCWire *copy();
        int createWire(std::vector<OCCEdge *> edges);
        std::vector<DVec> tesselate(double factor, double angle);
        double length();
        TopoDS_Shape getShape() { return wire; }
        void setShape(TopoDS_Shape shape) { wire = TopoDS::Wire(shape); }
};

class OCCFace : public OCCBase {
    public:
        TopoDS_Face face;
        OCCFace() { ; }
        OCCFace *copy();
        int createFace(OCCWire *wire);
        int createConstrained(std::vector<OCCEdge *> edges, std::vector<DVec> points);
        double area();
        DVec inertia();
        DVec centreOfMass();
        std::vector<DVec> tesselate(double factor, double angle);
        int createPolygonal(std::vector<DVec> points);
        int extrude(OCCEdge *edge, DVec p1, DVec p2);
        int revolve(OCCEdge *edge, DVec p1, DVec p2, double angle);
        OCCMesh *createMesh(double defle, double angle);
        TopoDS_Shape getShape() { return face; }
        void setShape(TopoDS_Shape shape) { face = TopoDS::Face(shape); }
};

typedef int (*filter_func)(void *user_data, double *near, double *far);

class OCCSolid : public OCCBase {
    public:
        TopoDS_Shape solid;
        OCCSolid() { ; }
        int createSolid(std::vector<OCCFace *> faces, double tolerance);
        double area();
        double volume();
        DVec inertia();
        DVec centreOfMass();
        OCCSolid *copy();
        OCCMesh *createMesh(double defle, double angle);
        int addSolids(std::vector<OCCSolid *> solids);
        int createSphere(DVec center, double radius);
        int createCylinder(DVec p1, DVec p2, double radius);
        int createTorus(DVec p1, DVec p2, double radius1, double radius2);
        int createCone(DVec p1, DVec p2, double radius1, double radius2);
        int createBox(DVec p1, DVec p2);
        int createPrism(OCCFace *face, DVec normal, bool isInfinite);
        int extrude(OCCFace *face, DVec p1, DVec p2);
        int revolve(OCCFace *face, DVec p1, DVec p2, double angle);
        int loft(std::vector<OCCBase *> profiles, bool ruled, double tolerance);
        int sweep(OCCWire *spine, std::vector<OCCBase *> profiles, int cornerMode);
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
        TopoDS_Shape getShape() { return solid; }
        void setShape(TopoDS_Shape shape) { solid = shape; }
};

int extractFaceMesh(TopoDS_Face face, OCCMesh *mesh);
void connectEdges (std::vector<TopoDS_Edge>& edges, std::vector<TopoDS_Wire>& wires);