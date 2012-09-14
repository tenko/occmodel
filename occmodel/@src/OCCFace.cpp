// Gmsh - Copyright (C) 1997-2011 C. Geuzaine, J.-F. Remacle
//
// See the LICENSE.txt file for license information. Please report all
// bugs and problems to <gmsh@geuz.org>.
#include "OCCModel.h"

OCCFace *OCCFace::copy()
{
    OCCFace *ret = new OCCFace();
    try {
        BRepBuilderAPI_Copy A;
        A.Perform(face);
        ret->face = TopoDS::Face(A.Shape());
    } catch(Standard_Failure &err) {
        return NULL;
    }
    return ret;
}

int OCCFace::translate(DVec delta)
{
    try {
        gp_Trsf trans;
        trans.SetTranslation(gp_Pnt(0,0,0), gp_Pnt(delta[0],delta[1],delta[2]));
        TopLoc_Location loc = face.Location();
        gp_Trsf placement = loc.Transformation();
        trans = placement * trans;
        BRepBuilderAPI_Transform aTrans(face, trans, Standard_False);
        face = TopoDS::Face(aTrans.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCFace::rotate(DVec p1, DVec p2, double angle)
{
    try {
        gp_Trsf trans;
        gp_Vec dir(gp_Pnt(p1[0], p1[1], p1[2]), gp_Pnt(p2[0], p2[1], p2[2]));
        gp_Ax1 axis(gp_Pnt(p1[0], p1[1], p1[2]), dir);
        trans.SetRotation(axis, angle);
        TopLoc_Location loc = face.Location();
        gp_Trsf placement = loc.Transformation();
        trans = placement * trans;
        BRepBuilderAPI_Transform aTrans(face, trans, Standard_False);
        face = TopoDS::Face(aTrans.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCFace::scale(DVec pnt, double scale)
{
    try {
        gp_Trsf trans;
        trans.SetScale(gp_Pnt(pnt[0],pnt[1],pnt[2]), scale);
        TopLoc_Location loc = face.Location();
        gp_Trsf placement = loc.Transformation();
        trans = placement * trans;
        BRepBuilderAPI_Transform aTrans(face, trans, Standard_True);
        face = TopoDS::Face(aTrans.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCFace::mirror(DVec pnt, DVec nor)
{
    try {
        gp_Ax2 ax2(gp_Pnt(pnt[0],pnt[1],pnt[2]), gp_Dir(nor[0],nor[1],nor[2]));
        gp_Trsf trans;
        trans.SetMirror(ax2);
        TopLoc_Location loc = face.Location();
        gp_Trsf placement = loc.Transformation();
        trans = placement * trans;
        BRepBuilderAPI_Transform aTrans(face, trans, Standard_False);
        face = TopoDS::Face(aTrans.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCFace::createFace(OCCWire *wire) {
    try {
        face = BRepBuilderAPI_MakeFace(wire->getShape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCFace::createConstrained(std::vector<OCCEdge *> edges, std::vector<DVec> points) {
    try {
        BRepOffsetAPI_MakeFilling aGenerator;
        for (unsigned i = 0; i < edges.size(); i++) {
            OCCEdge *edge = edges[i];
            aGenerator.Add(edge->getShape(), GeomAbs_C0);
        }
        for (unsigned i = 0; i < points.size(); i++) {
            gp_Pnt aPnt(points[i][0], points[i][1], points[i][2]);
            aGenerator.Add(aPnt);
        }
        aGenerator.Build();
        face = TopoDS::Face(aGenerator.Shape());
        
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

DVec OCCFace::boundingBox()
{
    DVec ret;
    try {
        Bnd_Box aBox;
        BRepBndLib::Add(face, aBox);
        Standard_Real aXmin, aYmin, aZmin;
        Standard_Real aXmax, aYmax, aZmax;
        aBox.Get(aXmin, aYmin, aZmin, aXmax, aYmax, aZmax);
        ret.push_back(aXmin);
        ret.push_back(aYmin);
        ret.push_back(aZmin);
        ret.push_back(aXmax);
        ret.push_back(aYmax);
        ret.push_back(aZmax);
    } catch(Standard_Failure &err) {
        ret.push_back(0.0);
        ret.push_back(0.0);
        ret.push_back(0.0);
        ret.push_back(0.0);
        ret.push_back(0.0);
        ret.push_back(0.0);
    }
    return ret;
}

double OCCFace::area() {
    GProp_GProps prop;
    BRepGProp::SurfaceProperties(face, prop);
    return prop.Mass();
}

DVec OCCFace::inertia() {
    DVec ret;
    GProp_GProps prop;
    BRepGProp::SurfaceProperties(face, prop);
    gp_Mat mat = prop.MatrixOfInertia();
    ret.push_back(mat(1,1)); // Ixx
    ret.push_back(mat(2,2)); // Iyy
    ret.push_back(mat(3,3)); // Izz
    ret.push_back(mat(1,2)); // Ixy
    ret.push_back(mat(1,3)); // Ixz
    ret.push_back(mat(2,3)); // Iyz
    return ret;
}

DVec OCCFace::centreOfMass() {
    DVec ret;
    GProp_GProps prop;
    BRepGProp::SurfaceProperties(face, prop);
    gp_Pnt cg = prop.CentreOfMass();
    ret.push_back(cg.X());
    ret.push_back(cg.Y());
    ret.push_back(cg.Z());
    return ret;
}

int OCCFace::createPolygonal(std::vector<DVec> points)
{
    try {
        BRepBuilderAPI_MakePolygon MP;
        for (unsigned i=0; i<points.size(); i++) {
            MP.Add(gp_Pnt(points[i][0], points[i][1], points[i][2]));
        }
        MP.Close();
        if (!MP.IsDone())
            return 1;
        BRepBuilderAPI_MakeFace MF(MP.Wire(), false);
        face = MF.Face();
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCFace::extrude(OCCEdge *edge, DVec p1, DVec p2) {
    try {
        gp_Vec direction(gp_Pnt(p1[0], p1[1], p1[2]),
                         gp_Pnt(p2[0], p2[1], p2[2]));
        gp_Ax1 axisOfRevolution(gp_Pnt(p1[0], p1[1], p1[2]), direction);

        BRepPrimAPI_MakePrism MP(edge->getShape(), direction,
                                 Standard_False);
        face = TopoDS::Face(MP.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCFace::revolve(OCCEdge *edge, DVec p1, DVec p2, double angle)
{
    try {
        gp_Dir direction(p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2]);
        gp_Ax1 axisOfRevolution(gp_Pnt(p1[0], p1[1], p1[2]), direction);
        BRepPrimAPI_MakeRevol MR(edge->getShape(), axisOfRevolution, angle, Standard_False);
        face = TopoDS::Face(MR.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

OCCMesh *OCCFace::createMesh(double factor, double angle)
{
    OCCMesh *mesh = new OCCMesh();
    
    try {
        Bnd_Box aBox;
        BRepBndLib::Add(face, aBox);
        
        Standard_Real aXmin, aYmin, aZmin;
        Standard_Real aXmax, aYmax, aZmax;
        aBox.Get(aXmin, aYmin, aZmin, aXmax, aYmax, aZmax);
        
        Standard_Real maxd = fabs(aXmax - aXmin);
        maxd = std::max(maxd, fabs(aYmax - aYmin));
        maxd = std::max(maxd, fabs(aZmax - aZmin));
        
        BRepMesh_FastDiscret MSH(factor*maxd, angle, aBox, Standard_False, Standard_False, 
                                 Standard_True, Standard_True);
        
        MSH.Perform(face);
        
        BRepMesh::Mesh(face,factor*maxd);
        
        if (extractFaceMesh(face, mesh) == 1)
            return NULL;
    } catch(Standard_Failure &err) {
        return NULL;
    }
    return mesh;
}