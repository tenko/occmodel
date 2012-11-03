// Copyright 2012 by Runar Tenfjord, Tenko as.
// See LICENSE.txt for details on conditions.
#ifndef OCCMODEL_H
#define OCCMODEL_H
#include "OCCIncludes.h"
#include <sstream>
#include <math.h>
#include <limits>
#include <vector>
#include <set>
#include <map>
#include <list>
#include <algorithm>

typedef std::vector<float> FVec;
typedef std::vector<double> DVec;
typedef std::vector<int> IVec;

struct OCCStruct3d {
    double x;
    double y;
    double z;
};

struct OCCStruct3f {
    float x;
    float y;
    float z;
};

struct OCCStruct3I {
    unsigned int i;
    unsigned int j;
    unsigned int k;
};

struct OptFace;

struct OptVertex
{
	unsigned int           index;  // Index in vertex array
	float                  score;
	std::set<OptFace *>    faces;  // Faces that are using this vertex
	void updateScore(int cacheIndex);
};

struct OptFace
{
	OptVertex  *verts[3];
	float getScore()  {return verts[0]->score + verts[1]->score + verts[2]->score;}
};

enum BoolOpType {BOOL_FUSE, BOOL_CUT, BOOL_COMMON};

class OCCBase;
class OCCSolid;

extern char errorMessage[256];
void setErrorMessage(const char *err);

class OCCTesselation {
    public:
        std::vector<OCCStruct3f> vertices;
        std::vector<unsigned int> ranges;
        OCCTesselation() { ; }
};

class OCCMesh {
    public:
        std::vector<OCCStruct3f> normals;
        std::vector<OCCStruct3f> vertices;
        std::vector<OCCStruct3I> triangles;
        std::vector<unsigned int> edgeindices;
        std::vector<int> edgeranges;
        std::vector<int> edgehash;
        OCCMesh() { ; }
        int extractFaceMesh(const TopoDS_Face& face, bool qualityNormals);
        void optimize();
};

class MeshOptimizer
{
public:
	static const unsigned int maxCacheSize = 16;
	static float calcCacheEfficiency(OCCMesh *mesh,
                                     const unsigned  int cacheSize = maxCacheSize);
	static void optimizeIndexOrder(OCCMesh *mesh);
};

unsigned int decutf8(unsigned int* state, unsigned int* codep, unsigned int byte);

void printShapeType(const TopoDS_Shape& shape);
int extractSubShape(const TopoDS_Shape& shape, std::vector<OCCBase *>& shapes);
int extractShape(const TopoDS_Shape& shape, std::vector<OCCBase *>& shapes);

class OCCTools {
public:
    static int writeBREP(const char *filename, std::vector<OCCBase *> shapes);
    static int writeBREP(std::ostream& str, const TopoDS_Shape& shape);
    static int writeSTEP(const char *filename, std::vector<OCCBase *> shapes);
    static int writeSTL(const char *filename, std::vector<OCCBase *> shapes);
    static int writeVRML(const char *filename, std::vector<OCCBase *> shapes);
    static int readBREP(const char *filename, std::vector<OCCBase *>& shapes);
    static int readBREP(std::istream& str, TopoDS_Shape& shape);
    static int readSTEP(const char *filename, std::vector<OCCBase *>& shapes);
};

class OCCBase {
    public:
        int transform(DVec mat, OCCBase *target);
        int translate(OCCStruct3d delta, OCCBase *target);
        int rotate(double angle, OCCStruct3d p1, OCCStruct3d p2, OCCBase *target);
        int scale(OCCStruct3d pnt, double scale, OCCBase *target);
        int mirror(OCCStruct3d pnt, OCCStruct3d nor, OCCBase *target);
        DVec boundingBox(double tolerance);
        int findPlane(OCCStruct3d *origin, OCCStruct3d *normal, double tolerance);
        TopAbs_ShapeEnum shapeType();
        int hashCode();
        bool isEqual(OCCBase *other);
        bool isNull();
        bool isValid();
        bool fixShape();
        int toString(std::string *output);
        int fromString(std::string input);
        virtual bool canSetShape(const TopoDS_Shape&) { return true; }
        virtual const TopoDS_Shape& getShape() { return TopoDS_Shape(); }
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
        double X() const { 
            gp_Pnt pnt = BRep_Tool::Pnt(vertex);
            return pnt.X();
        }
        double Y() const { 
            gp_Pnt pnt = BRep_Tool::Pnt(vertex);
            return pnt.Y();
        }
        double Z() const { 
            gp_Pnt pnt = BRep_Tool::Pnt(vertex);
            return pnt.Z();
        }
        bool canSetShape(const TopoDS_Shape& shape) {
            return shape.ShapeType() == TopAbs_VERTEX;
        }
        std::string typeName() { return std::string("OCCVertex"); }
        const TopoDS_Shape& getShape() { return vertex; }
        const TopoDS_Vertex& getVertex() { return vertex; }
        void setShape(TopoDS_Shape shape) { vertex = TopoDS::Vertex(shape); }
};

class OCCVertexIterator {
    public:
        TopExp_Explorer ex;
        OCCVertexIterator(OCCBase *arg) {
            ex.Init(arg->getShape(), TopAbs_VERTEX);
        }
        void reset() {
            ex.ReInit();
        }
        OCCVertex *next() {
            if (ex.More()) {
                OCCVertex *ret = new OCCVertex();
                ret->setShape(ex.Current());
                ex.Next();
                return ret;
            } else {
                return NULL;
            }
        }
};

class OCCEdge : public OCCBase {
    public:
        TopoDS_Edge edge;
        OCCEdge() { ; }
        bool isSeam(OCCBase *face);
        bool isDegenerated();
        bool isClosed();
        OCCEdge *copy(bool deepCopy);
        int numVertices();
        OCCTesselation *tesselate(double factor, double angle);
        int createLine(OCCVertex *start, OCCVertex *end);
        int createArc(OCCVertex *start, OCCVertex *end, OCCStruct3d center);
        int createArc3P(OCCVertex *start, OCCVertex *end, OCCStruct3d pnt);
        int createCircle(OCCStruct3d center, OCCStruct3d normal, double radius);
        int createEllipse(OCCStruct3d pnt, OCCStruct3d nor, double rMajor, double rMinor);
        int createHelix(double pitch, double height, double radius, double angle,
                        bool leftHanded);
        int createBezier(OCCVertex *start, OCCVertex *end, std::vector<OCCStruct3d> points);
        int createSpline(OCCVertex *start, OCCVertex *end, std::vector<OCCStruct3d> points,
                         double tolerance);
        int createNURBS(OCCVertex *start, OCCVertex *end, std::vector<OCCStruct3d> points,
                        DVec knots, DVec weights, IVec mult);
        double length();
        bool canSetShape(const TopoDS_Shape& shape) {
            return shape.ShapeType() == TopAbs_EDGE;
        }
        const TopoDS_Shape& getShape() { return edge; }
        const TopoDS_Edge& getEdge() { return edge; }
        void setShape(TopoDS_Shape shape) { edge = TopoDS::Edge(shape); }
};

class OCCEdgeIterator {
    public:
        TopExp_Explorer ex;
        OCCEdgeIterator(OCCBase *arg) {
            ex.Init(arg->getShape(), TopAbs_EDGE);
        }
        void reset() {
            ex.ReInit();
        }
        OCCEdge *next() {
            if (ex.More()) {
                OCCEdge *ret = new OCCEdge();
                ret->setShape(ex.Current());
                ex.Next();
                return ret;
            } else {
                return NULL;
            }
        }
};

class OCCWire : public OCCBase {
    public:
        TopoDS_Wire wire;
        OCCWire() { ; }
        OCCWire *copy(bool deepCopy);
        int numVertices();
        int numEdges();
        bool isClosed();
        int createWire(std::vector<OCCEdge *> edges);
        int project(OCCBase *face);
        int offset(double distance, int joinType);
        int fillet(std::vector<OCCVertex *> vertices, std::vector<double> radius);
        int chamfer(std::vector<OCCVertex *> vertices, std::vector<double> distances);
        OCCTesselation *tesselate(double factor, double angle);
        double length();
        bool canSetShape(const TopoDS_Shape& shape) {
            return shape.ShapeType() == TopAbs_WIRE;
        }
        const TopoDS_Shape& getShape() { return wire; }
        const TopoDS_Wire& getWire() { return wire; }
        void setShape(TopoDS_Shape shape) { wire = TopoDS::Wire(shape); }
};

class OCCWireIterator {
    public:
        TopExp_Explorer ex;
        OCCWireIterator(OCCBase *arg) {
            ex.Init(arg->getShape(), TopAbs_WIRE);
        }
        void reset() {
            ex.ReInit();
        }
        OCCWire *next() {
            if (ex.More()) {
                OCCWire *ret = new OCCWire();
                ret->setShape(ex.Current());
                ex.Next();
                return ret;
            } else {
                return NULL;
            }
        }
};

class OCCFace : public OCCBase {
    public:
        TopoDS_Shape face;
        OCCFace() { ; }
        OCCFace *copy(bool deepCopy);
        int numWires();
        int numFaces();
        int createFace(std::vector<OCCWire *> wires);
        int createConstrained(std::vector<OCCEdge *> edges, std::vector<OCCStruct3d> points);
        double area();
        DVec inertia();
        OCCStruct3d centreOfMass();
        int createPolygonal(std::vector<OCCStruct3d> points);
        int offset(double offset, double tolerance);
        int extrude(OCCBase *shape, OCCStruct3d p1, OCCStruct3d p2);
        int revolve(OCCBase *shape, OCCStruct3d p1, OCCStruct3d p2, double angle);
        int sweep(OCCWire *spine, std::vector<OCCBase *> profiles, int cornerMode);
        int loft(std::vector<OCCBase *> profiles, bool ruled, double tolerance);
        int boolean(OCCSolid *tool, BoolOpType op);
        OCCMesh *createMesh(double defle, double angle, bool qualityNormals);
        bool canSetShape(const TopoDS_Shape& shape) {
            return shape.ShapeType() == TopAbs_FACE || shape.ShapeType() == TopAbs_SHELL;
        }
        const TopoDS_Shape& getShape() { return face; }
        const TopoDS_Face& getFace() { return TopoDS::Face(face); }
        const TopoDS_Shell& getShell() { return TopoDS::Shell(face); }
        void setShape(TopoDS_Shape shape) { face = shape; }
};

class OCCFaceIterator {
    public:
        TopExp_Explorer ex;
        OCCFaceIterator(OCCBase *arg) {
            ex.Init(arg->getShape(), TopAbs_FACE);
        }
        void reset() {
            ex.ReInit();
        }
        OCCFace *next() {
            if (ex.More()) {
                OCCFace *ret = new OCCFace();
                ret->setShape(ex.Current());
                ex.Next();
                return ret;
            } else {
                return NULL;
            }
        }
};

class OCCSolid : public OCCBase {
    public:
        TopoDS_Shape solid;
        OCCSolid() { ; }
        OCCSolid *copy(bool deepCopy);
        int numSolids();
        int numFaces();
        int createSolid(std::vector<OCCFace *> faces, double tolerance);
        double area() ;
        double volume();
        DVec inertia();
        OCCStruct3d centreOfMass();
        OCCMesh *createMesh(double defle, double angle, bool qualityNormals);
        int addSolids(std::vector<OCCSolid *> solids);
        int createSphere(OCCStruct3d center, double radius);
        int createCylinder(OCCStruct3d p1, OCCStruct3d p2, double radius);
        int createTorus(OCCStruct3d p1, OCCStruct3d p2, double ringRadius, double radius);
        int createCone(OCCStruct3d p1, OCCStruct3d p2, double radius1, double radius2);
        int createBox(OCCStruct3d p1, OCCStruct3d p2);
        int createPrism(OCCFace *face, OCCStruct3d normal, bool isInfinite);
        int createText(double height, double depth, const char *text, const char *fontpath);
        int extrude(OCCFace *face, OCCStruct3d p1, OCCStruct3d p2);
        int revolve(OCCFace *face, OCCStruct3d p1, OCCStruct3d p2, double angle);
        int loft(std::vector<OCCBase *> profiles, bool ruled, double tolerance);
        int pipe(OCCFace *face, OCCWire *wire);
        int sweep(OCCWire *spine, std::vector<OCCBase *> profiles, int cornerMode);
        int boolean(OCCSolid *tool, BoolOpType op);
        int fillet(std::vector<OCCEdge *> edges, std::vector<double> radius);
        int chamfer(std::vector<OCCEdge *> edges, std::vector<double> distances);
        int shell(std::vector<OCCFace *> faces, double offset, double tolerance);
        int offset(OCCFace *face, double offset, double tolerance);
        OCCFace *section(OCCStruct3d pnt, OCCStruct3d nor);
        bool canSetShape(const TopoDS_Shape& shape) {
            TopAbs_ShapeEnum type = shape.ShapeType();
            return type == TopAbs_SOLID || type == TopAbs_COMPSOLID || type == TopAbs_COMPOUND;
        }
        const TopoDS_Shape& getShape() { return solid; }
        const TopoDS_Shape& getSolid() { return solid; }
        void setShape(TopoDS_Shape shape);
};

class OCCSolidIterator {
    public:
        TopExp_Explorer ex;
        OCCSolidIterator(OCCBase *arg) {
            ex.Init(arg->getShape(), TopAbs_SOLID);
        }
        void reset() {
            ex.ReInit();
        }
        OCCSolid *next() {
            if (ex.More()) {
                OCCSolid *ret = new OCCSolid();
                ret->setShape(ex.Current());
                ex.Next();
                return ret;
            } else {
                return NULL;
            }
        }
};
#endif
