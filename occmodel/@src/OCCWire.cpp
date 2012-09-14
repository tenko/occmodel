// Gmsh - Copyright (C) 1997-2011 C. Geuzaine, J.-F. Remacle
//
// See the LICENSE.txt file for license information. Please report all
// bugs and problems to <gmsh@geuz.org>.
#include "OCCModel.h"

OCCWire *OCCWire::copy()
{
    OCCWire *ret = new OCCWire();
    try {
        BRepBuilderAPI_Copy A;
        A.Perform(wire);
        ret->wire = TopoDS::Wire(A.Shape());
    } catch(Standard_Failure &err) {
        return NULL;
    }
    return ret;
}

int OCCWire::createWire(std::vector<OCCEdge *> edges)
{
    try {
        BRepBuilderAPI_MakeWire wm;
        for (unsigned i=0; i<edges.size(); i++) {
            OCCEdge *edge = edges[i];
            wm.Add(edge->getShape());
        }
        wire = wm.Wire();
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

std::vector<DVec> OCCWire::tesselate(double angular, double curvature)
{
    std::vector<DVec> ret;
    try {
        Standard_Real start, end;
        DVec dtmp;
        
        // explore wire edges in connected order
        BRepTools_WireExplorer exWire;
        for (exWire.Init(wire); exWire.More(); exWire.Next()) {
            TopoDS_Edge edge = exWire.Current();
            TopLoc_Location loc = edge.Location();
            gp_Trsf location = loc.Transformation();
            
            Handle(Geom_Curve) curve = BRep_Tool::Curve(edge, start, end);
            GeomAdaptor_Curve aCurve(curve);
            
            GCPnts_TangentialDeflection TD(aCurve, start, end, angular, curvature);
            
            for (Standard_Integer i = 1; i <= TD.NbPoints(); i++)
            {
                gp_Pnt pnt = TD.Value(i).Transformed(location);
                dtmp.clear();
                dtmp.push_back(pnt.X());
                dtmp.push_back(pnt.Y());
                dtmp.push_back(pnt.Z());
                ret.push_back(dtmp);
            }
        }
    } catch(Standard_Failure &err) {
        return ret;
    }
    return ret;
}

int OCCWire::translate(DVec delta)
{
    try {
        gp_Trsf trans;
        trans.SetTranslation(gp_Pnt(0,0,0), gp_Pnt(delta[0],delta[1],delta[2]));
        TopLoc_Location loc = wire.Location();
        gp_Trsf placement = loc.Transformation();
        trans = placement * trans;
        BRepBuilderAPI_Transform aTrans(wire, trans, Standard_False);
        wire = TopoDS::Wire(aTrans.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCWire::rotate(DVec p1, DVec p2, double angle)
{
    try {
        gp_Trsf trans;
        gp_Vec dir(gp_Pnt(p1[0], p1[1], p1[2]), gp_Pnt(p2[0], p2[1], p2[2]));
        gp_Ax1 axis(gp_Pnt(p1[0], p1[1], p1[2]), dir);
        trans.SetRotation(axis, angle);
        TopLoc_Location loc = wire.Location();
        gp_Trsf placement = loc.Transformation();
        trans = placement * trans;
        BRepBuilderAPI_Transform aTrans(wire, trans, Standard_False);
        wire = TopoDS::Wire(aTrans.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCWire::scale(DVec pnt, double scale)
{
    try {
        gp_Trsf trans;
        trans.SetScale(gp_Pnt(pnt[0],pnt[1],pnt[2]), scale);
        TopLoc_Location loc = wire.Location();
        gp_Trsf placement = loc.Transformation();
        trans = placement * trans;
        BRepBuilderAPI_Transform aTrans(wire, trans, Standard_True);
        wire = TopoDS::Wire(aTrans.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCWire::mirror(DVec pnt, DVec nor)
{
    try {
        gp_Ax2 ax2(gp_Pnt(pnt[0],pnt[1],pnt[2]), gp_Dir(nor[0],nor[1],nor[2]));
        gp_Trsf trans;
        trans.SetMirror(ax2);
        TopLoc_Location loc = wire.Location();
        gp_Trsf placement = loc.Transformation();
        trans = placement * trans;
        BRepBuilderAPI_Transform aTrans(wire, trans, Standard_False);
        wire = TopoDS::Wire(aTrans.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

double OCCWire::length() {
    GProp_GProps prop;
    BRepGProp::LinearProperties(wire, prop);
    return prop.Mass();
}

DVec OCCWire::boundingBox()
{
    DVec ret;
    try {
        Bnd_Box aBox;
        BRepBndLib::Add(wire, aBox);
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