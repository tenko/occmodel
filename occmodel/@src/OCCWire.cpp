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
        ret->setShape(TopoDS::Wire(A.Shape()));
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
            wm.Add(edge->edge);
        }
        this->setShape(wm.Wire());
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

double OCCWire::length() {
    GProp_GProps prop;
    BRepGProp::LinearProperties(wire, prop);
    return prop.Mass();
}
