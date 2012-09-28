// Gmsh - Copyright (C) 1997-2011 C. Geuzaine, J.-F. Remacle
//
// See the LICENSE.txt file for license information. Please report all
// bugs and problems to <gmsh@geuz.org>.
#include "OCCModel.h"

OCCWire *OCCWire::copy(bool deepCopy = false)
{
    OCCWire *ret = new OCCWire();
    try {
        if (deepCopy) {
            BRepBuilderAPI_Copy A;
            A.Perform(this->getWire());
            ret->setShape(A.Shape());
        } else {
            ret->setShape(this->getShape());
        }
    } catch(Standard_Failure &err) {
        return NULL;
    }
    return ret;
}

int OCCWire::numVertices()
{
    TopTools_IndexedMapOfShape anIndices;
    TopExp::MapShapes(this->getWire(), TopAbs_VERTEX, anIndices);
    return anIndices.Extent();
}

int OCCWire::numEdges()
{
    TopTools_IndexedMapOfShape anIndices;
    TopExp::MapShapes(this->getWire(), TopAbs_EDGE, anIndices);
    return anIndices.Extent();
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

int OCCWire::project(OCCBase *face) {
    std::vector<TopoDS_Wire> wires;
    std::vector<TopoDS_Edge> edges;
    TopExp_Explorer ex;
    try {
        BRepOffsetAPI_NormalProjection NP(face->getShape());
        NP.SetLimit(Standard_True);
        NP.Add(this->getWire());
        NP.Build();
        if (!NP.IsDone())
            return 1;
        
        for (ex.Init(NP.Shape(), TopAbs_EDGE); ex.More(); ex.Next()) {
            if (!ex.Current().IsNull()) {
                edges.push_back(TopoDS::Edge(ex.Current()));
            }
        }
        connectEdges(edges, wires);
        if (wires.size() != 1)
            return 1;
        
        this->setShape(wires[0]);
        
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCWire::offset(double distance, int joinType = 0) {
    try {
        GeomAbs_JoinType join = GeomAbs_Arc;
        switch (joinType) {
            case 1:
                join = GeomAbs_Tangent;
                break;
            case 2:
                join = GeomAbs_Intersection;
                break;
        }   
        BRepOffsetAPI_MakeOffset MO(this->getWire(), join);
        MO.Perform(distance);
        this->setShape(MO.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCWire::fillet(std::vector<OCCVertex *> vertices, std::vector<double> radius) {
    int vertices_size = vertices.size();
    int radius_size = radius.size();
    
    BRepFilletAPI_MakeFillet2d MF;
    try {
        MF.Init(BRepBuilderAPI_MakeFace(this->getWire()));
        
        for (unsigned i=0; i<vertices.size(); i++) {
            OCCVertex *vertex = vertices[i];
            
            if (radius_size == 1) {
                // single radius
                MF.AddFillet(vertex->getVertex(), radius[0]);
            } else if (radius_size == vertices_size) {
                // radius given for each vertex
                MF.AddFillet(vertex->getVertex(), radius[i]);
            } else {
                return 1;
            }
        }
        
        if(MF.Status() != ChFi2d_IsDone)
            return 1;
        
        BRepBuilderAPI_MakeWire wire;
        TopTools_IndexedMapOfShape aMap;
        BRepTools_WireExplorer Ex;
        
        TopExp::MapShapes(MF.Shape(), TopAbs_WIRE, aMap);
        if(aMap.Extent() != 1)
            return 1;
        
        //add edges to the wire
        Ex.Clear();
        for(Ex.Init(TopoDS::Wire(aMap(1))); Ex.More(); Ex.Next())
        {
            wire.Add(Ex.Current());
        }
          
        this->setShape(wire);
        
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCWire::chamfer(std::vector<OCCVertex *> vertices, std::vector<double> distances) {
    int vertices_size = vertices.size();
    int distances_size = distances.size();
    
    BRepFilletAPI_MakeFillet2d MF;
    try {
        MF.Init(BRepBuilderAPI_MakeFace(this->getWire()));
        
        // creat map of vertices
        TopTools_IndexedMapOfShape vertMap;
        for (unsigned i=0; i<vertices.size(); i++)
            vertMap.Add(vertices[i]->getShape());
        
        bool first = true;
        TopoDS_Edge firstEdge, nextEdge;
        TopoDS_Vertex vertex;
        
        BRepTools_WireExplorer Ex1;
        for (Ex1.Init(this->getWire()); Ex1.More(); ) {
            if(first == true) {
                firstEdge = Ex1.Current();
                first = false;                                                    
            }

            Ex1.Next();
            
            //if the number of edges is odd don't proceed
            if(Ex1.More() == Standard_False)     
                break;
            
            nextEdge = Ex1.Current();
            
            //get the common vertex of the two edges
            if (!TopExp::CommonVertex(firstEdge, nextEdge, vertex)) {
                // disconnected wire
                first = true;
                continue;
            }
            
            if (vertMap.Contains(vertex)) {
                int i = vertMap.FindIndex(vertex) - 1;
                
                if (distances_size == 1) {
                    // single distance
                    MF.AddChamfer(firstEdge, nextEdge, distances[0], distances[0]);
                } else if (distances_size == vertices_size) {
                    // distance given for each vertex
                    MF.AddChamfer(firstEdge, nextEdge, distances[i], distances[i]);
                } else {
                    return 1;
                }
            
            }
            
            firstEdge = nextEdge;
        }
        
        if(MF.Status() != ChFi2d_IsDone)
            return 1;
        
        TopTools_IndexedMapOfShape aMap;
        TopExp::MapShapes(MF.Shape(), TopAbs_WIRE, aMap);
        if(aMap.Extent() != 1)
            return 1;
        
        //add edges to the wire
        BRepBuilderAPI_MakeWire wire;
        BRepTools_WireExplorer Ex2;
        for(Ex2.Init(TopoDS::Wire(aMap(1))); Ex2.More(); Ex2.Next())
        {
            wire.Add(Ex2.Current());
        }
          
        this->setShape(wire.Shape());
        
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
        int idx = 1;
        BRepTools_WireExplorer exWire;
        for (exWire.Init(this->getWire()); exWire.More(); exWire.Next()) {
            const TopoDS_Edge& edge = exWire.Current();
            TopLoc_Location loc = edge.Location();
            gp_Trsf location = loc.Transformation();
            
            const Handle(Geom_Curve)& curve = BRep_Tool::Curve(edge, start, end);
            const GeomAdaptor_Curve& aCurve(curve);
            
            GCPnts_TangentialDeflection TD(aCurve, start, end, angular, curvature);
            
            for (Standard_Integer i = 1; i <= TD.NbPoints(); i++)
            {
                if (idx == 1)
                    idx = 2;
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
    BRepGProp::LinearProperties(this->getWire(), prop);
    return prop.Mass();
}
