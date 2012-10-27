// Copyright 2012 by Runar Tenfjord, Tenko as.
// See LICENSE.txt for details on conditions.
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
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to copy wire");
        }
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

bool OCCWire::isClosed()
{
    TopoDS_Vertex aV1, aV2;
    TopExp::Vertices(this->getWire(), aV1, aV2);
    if (!aV1.IsNull() && !aV2.IsNull() && aV1.IsSame(aV2))
        return true;
    return false;
}

int OCCWire::createWire(std::vector<OCCEdge *> edges)
{
    try {
        BRepBuilderAPI_MakeWire MW;
        for (unsigned i=0; i<edges.size(); i++) {
            OCCEdge *edge = edges[i];
            MW.Add(edge->getEdge());
        }
        
        BRepBuilderAPI_WireError error = MW.Error();
        switch (error)
        {
            case BRepBuilderAPI_EmptyWire:
            {
                StdFail_NotDone::Raise("Wire empty");
                break;
            }
            case BRepBuilderAPI_DisconnectedWire:
            {
                StdFail_NotDone::Raise("Disconnected wire");
                break;
            }
            case BRepBuilderAPI_NonManifoldWire :
            {
                StdFail_NotDone::Raise("non-manifold wire");
                break;
            }
        }
        
        this->setShape(MW.Wire());
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to create wire");
        }
        return 0;
    }
    return 1;
}

int OCCWire::project(OCCBase *face) {
    Handle(TopTools_HSequenceOfShape) wires = new TopTools_HSequenceOfShape;
    Handle(TopTools_HSequenceOfShape) edges = new TopTools_HSequenceOfShape;
    TopExp_Explorer ex;
    try {
        BRepOffsetAPI_NormalProjection NP(face->getShape());
        NP.SetLimit(Standard_True);
        NP.Add(this->getWire());
        NP.Build();
        if (!NP.IsDone())
            StdFail_NotDone::Raise("project operation failed");
        
        for (ex.Init(NP.Shape(), TopAbs_EDGE); ex.More(); ex.Next()) {
            if (!ex.Current().IsNull()) {
                edges->Append(TopoDS::Edge(ex.Current()));
            }
        }
        ShapeAnalysis_FreeBounds::ConnectEdgesToWires(edges,Precision::Confusion(),Standard_True,wires);
        if (wires->Length() != 1)
            StdFail_NotDone::Raise("project operation created empty result");
        
        this->setShape(wires->Value(1));
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to project wire");
        }
        return 0;
    }
    return 1;
}

int OCCWire::offset(double distance, int joinType = 0) {
    Handle(TopTools_HSequenceOfShape) wires = new TopTools_HSequenceOfShape;
    Handle(TopTools_HSequenceOfShape) edges = new TopTools_HSequenceOfShape;
    TopExp_Explorer ex;
    
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
        
        for (ex.Init(MO.Shape(), TopAbs_EDGE); ex.More(); ex.Next()) {
            if (!ex.Current().IsNull()) {
                edges->Append(TopoDS::Edge(ex.Current()));
            }
        }
        ShapeAnalysis_FreeBounds::ConnectEdgesToWires(edges,Precision::Confusion(),Standard_True,wires);
        if (wires->Length() != 1)
            StdFail_NotDone::Raise("offset operation created empty result");
        
        this->setShape(wires->Value(1));
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to offset wire");
        }
        return 0;
    }
    return 1;
}

int OCCWire::fillet(std::vector<OCCVertex *> vertices, std::vector<double> radius) {
    int vertices_size = vertices.size();
    int radius_size = radius.size();
    
    BRepFilletAPI_MakeFillet2d MF;
    try {
        if (this->getShape().IsNull()) {
            StdFail_NotDone::Raise("Shapes is Null");
        }
        
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
                StdFail_NotDone::Raise("radius argument has wrong size");
            }
        }
        
        if(MF.Status() != ChFi2d_IsDone)
            StdFail_NotDone::Raise("fillet not completed");
        
        BRepBuilderAPI_MakeWire wire;
        TopTools_IndexedMapOfShape aMap;
        BRepTools_WireExplorer Ex;
        
        TopExp::MapShapes(MF.Shape(), TopAbs_WIRE, aMap);
        if(aMap.Extent() != 1)
            StdFail_NotDone::Raise("Fillet operation did not result in single wire");
        
        //add edges to the wire
        Ex.Clear();
        for(Ex.Init(TopoDS::Wire(aMap(1))); Ex.More(); Ex.Next())
        {
            wire.Add(Ex.Current());
        }
          
        this->setShape(wire);
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to fillet wire");
        }
        return 0;
    }
    return 1;
}

int OCCWire::chamfer(std::vector<OCCVertex *> vertices, std::vector<double> distances) {
    int vertices_size = vertices.size();
    int distances_size = distances.size();
    
    BRepFilletAPI_MakeFillet2d MF;
    try {
        if (this->getShape().IsNull()) {
            StdFail_NotDone::Raise("Shapes is Null");
        }
        
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
                    StdFail_NotDone::Raise("distances argument has wrong size");
                }
            
            }
            
            firstEdge = nextEdge;
        }
        
        // special case for closed wire
        if (isClosed()) {
            // find seam vertex
            TopoDS_Vertex aV1;
            TopExp::Vertices(this->getWire(), vertex, aV1);
            
            // check if seam vertex has chamfer value
            if (vertMap.Contains(vertex)) {
                int i = vertMap.FindIndex(vertex) - 1;
                
                // map vertices to edges to find edge pair
                TopTools_IndexedDataMapOfShapeListOfShape mapVertexEdge;
                TopExp::MapShapesAndAncestors(this->getWire(), TopAbs_VERTEX, TopAbs_EDGE, mapVertexEdge);
                
                const TopTools_ListOfShape& edges = mapVertexEdge.FindFromKey(vertex);
                firstEdge = TopoDS::Edge(edges.First());
                nextEdge = TopoDS::Edge(edges.Last());
                
                if (distances_size == 1) {
                    // single distance
                    MF.AddChamfer(firstEdge, nextEdge, distances[0], distances[0]);
                } else if (distances_size == vertices_size) {
                    // distance given for each vertex
                    MF.AddChamfer(firstEdge, nextEdge, distances[i], distances[i]);
                } else {
                    StdFail_NotDone::Raise("distances argument has wrong size");
                }
            }
        }
        
        if(MF.Status() != ChFi2d_IsDone)
            StdFail_NotDone::Raise("chamfer operation failed");
        
        TopTools_IndexedMapOfShape aMap;
        TopExp::MapShapes(MF.Shape(), TopAbs_WIRE, aMap);
        if(aMap.Extent() != 1)
            StdFail_NotDone::Raise("chamfer result did not result in single wire");;
        
        //add edges to the wire
        BRepBuilderAPI_MakeWire wire;
        BRepTools_WireExplorer Ex2;
        for(Ex2.Init(TopoDS::Wire(aMap(1))); Ex2.More(); Ex2.Next())
        {
            wire.Add(Ex2.Current());
        }
          
        this->setShape(wire.Shape());
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to chamfer wire");
        }
        return 0;
    }
    return 1;
}

OCCTesselation *OCCWire::tesselate(double angular, double curvature)
{
    OCCTesselation *ret = new OCCTesselation();
    try {
        Standard_Real start, end;
        OCCStruct3f dtmp;
        
        // explore wire edges in connected order
        int lastSize = 0;
        BRepTools_WireExplorer exWire;
        
        for (exWire.Init(this->getWire()); exWire.More(); exWire.Next()) {
            const TopoDS_Edge& edge = exWire.Current();
            TopLoc_Location loc = edge.Location();
            gp_Trsf location = loc.Transformation();
            
            const Handle(Geom_Curve)& curve = BRep_Tool::Curve(edge, start, end);
            const GeomAdaptor_Curve& aCurve(curve);
            
            GCPnts_TangentialDeflection TD(aCurve, start, end, angular, curvature);
            
            ret->ranges.push_back(ret->vertices.size());
            
            for (Standard_Integer i = 1; i <= TD.NbPoints(); i++)
            {
                gp_Pnt pnt = TD.Value(i).Transformed(location);
                dtmp.x = (float)pnt.X();
                dtmp.y = (float)pnt.Y();
                dtmp.z = (float)pnt.Z();
                ret->vertices.push_back(dtmp);
            }
            
            ret->ranges.push_back(ret->vertices.size() - lastSize);
            lastSize = ret->vertices.size();
        }
    } catch(Standard_Failure &err) {
        return NULL;
    }
    return ret;
}

double OCCWire::length() {
    GProp_GProps prop;
    BRepGProp::LinearProperties(this->getWire(), prop);
    return prop.Mass();
}
