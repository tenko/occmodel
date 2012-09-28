// Gmsh - Copyright (C) 1997-2011 C. Geuzaine, J.-F. Remacle
//
// See the LICENSE.txt file for license information. Please report all
// bugs and problems to <gmsh@geuz.org>.
#include "OCCModel.h"

void printShapeType(const TopoDS_Shape& shape)
{
    if (!shape.IsNull()) {
        TopAbs_ShapeEnum type = shape.ShapeType();
        switch (type)
        {
        case TopAbs_COMPOUND:
            printf("TopAbs_COMPOUND\n");
            break;
        case TopAbs_COMPSOLID:
            printf("TopAbs_COMPSOLID\n");
            break;
        case TopAbs_SOLID:
            printf("TopAbs_SOLID\n");
            break;
        case TopAbs_SHELL:
            printf("TopAbs_SHELL\n");
            break;
        case TopAbs_FACE:
            printf("TopAbs_FACE\n");
            break;
        case TopAbs_WIRE:
            printf("TopAbs_WIRE\n");
            break;
        case TopAbs_EDGE:
            printf("TopAbs_EDGE\n");
        case TopAbs_VERTEX:
            printf("TopAbs_VERTEX\n");
            break;
        default:
            printf("Unknown\n");
            break;
        }
    }
    else {
        printf("Empty shape\n");
    }
}

int extractFaceMesh(const TopoDS_Face& face, OCCMesh *mesh, bool qualityNormals = false)
{
    int vsize = mesh->vertices.size();
    std::vector<gp_Vec> normals;
    bool reversed = false;
    DVec dtmp;
    IVec itmp;
    
    if(face.IsNull())
        return 1;
    
    try {
        TopLoc_Location loc;
        Handle(Poly_Triangulation) tri = BRep_Tool::Triangulation(face, loc);
        
        if(tri.IsNull())
            return 1;
        
        gp_Trsf tr = loc;
        const TColgp_Array1OfPnt& narr = tri->Nodes();
        for (int i = 1; i <= tri->NbNodes(); i++)
        {
            Standard_Real x,y,z;
            const gp_Pnt& pnt = narr(i);
            x = pnt.X();
            y = pnt.Y();
            z = pnt.Z();
            tr.Transforms(x,y,z);
            
            dtmp.clear();
            dtmp.push_back(x);
            dtmp.push_back(y);
            dtmp.push_back(z);
            mesh->vertices.push_back(dtmp);
            
            if (!qualityNormals)
                normals.push_back(gp_Vec(0.0,0.0,0.0));
        }
        
        if (face.Orientation() == TopAbs_REVERSED)
            reversed = true;
        
        const Poly_Array1OfTriangle& triarr = tri->Triangles();
        for (int i = 1; i <= tri->NbTriangles(); i++)
        {
            Poly_Triangle tri = triarr(i);
            Standard_Integer n1,n2,n3;
            
            if(reversed)
                tri.Get(n2,n1,n3);
            else
                tri.Get(n1,n2,n3);
            
            // make sure that we don't process invalid triangle
            if (n1 == n2 or n2 == n3 or n3 == n1)
                continue;
                
            // Calculate face normal
            const gp_Pnt& P1 = narr(n1);
            const gp_Pnt& P2 = narr(n2);
            const gp_Pnt& P3 = narr(n3);
            
            gp_Vec V1(P3.X() - P1.X(), P3.Y() - P1.Y(), P3.Z() - P1.Z());
            gp_Vec V2(P2.X() - P1.X(), P2.Y() - P1.Y(), P2.Z() - P1.Z());
            gp_Vec normal = V1.Crossed(V2);
            
            // Degenerated triangle
            if (normal.SquareMagnitude() < 1.0e-10)
                continue;
            
            itmp.clear();
            itmp.push_back(vsize + n1 - 1);
            itmp.push_back(vsize + n2 - 1);
            itmp.push_back(vsize + n3 - 1);
            mesh->triangles.push_back(itmp);
            
            if (!qualityNormals) {
                normals[n1 - 1] = normals[n1 - 1] - normal;
                normals[n2 - 1] = normals[n2 - 1] - normal;
                normals[n3 - 1] = normals[n3 - 1] - normal;
            }
        }
        
        if (qualityNormals) {
            gp_Dir normal;
            for (int i = 0; i < tri->NbNodes(); i++)
            {
                Handle_Geom_Surface surface = BRep_Tool::Surface(face);
                
                gp_Pnt vertex(mesh->vertices[i][0], mesh->vertices[i][1], mesh->vertices[i][2]);
                GeomAPI_ProjectPointOnSurf SrfProp(vertex, surface);
                Standard_Real fU, fV; SrfProp.Parameters(1, fU, fV);

                GeomLProp_SLProps faceprop(surface, fU, fV, 2, gp::Resolution());
                normal = faceprop.Normal();
                
                dtmp.clear();
                if (reversed) {
                    dtmp.push_back(-normal.X());
                    dtmp.push_back(-normal.Y());
                    dtmp.push_back(-normal.Z());
                } else {
                    dtmp.push_back(normal.X());
                    dtmp.push_back(normal.Y());
                    dtmp.push_back(normal.Z());
                }
                mesh->normals.push_back(dtmp);
            }
        } else {
            // Normalize vertex normals
            for (int i = 0; i < tri->NbNodes(); i++)
            {
                gp_Vec normal = normals[i];
                normal.Normalize();
                dtmp.clear();
                dtmp.push_back(normal.X());
                dtmp.push_back(normal.Y());
                dtmp.push_back(normal.Z());
                mesh->normals.push_back(dtmp);
            }
        }
        
    } catch(Standard_Failure &err) {
        //Handle_Standard_Failure e = Standard_Failure::Caught();
        //printf("ERROR: %s\n", e->GetMessageString());
        return 1;
    }
    
    return 0;
}

// connect induvidual edges to wires
void connectEdges(std::vector<TopoDS_Edge>& edges, std::vector<TopoDS_Wire>& wires)
{
    std::vector<TopoDS_Edge> edge_list = edges;
    while (edge_list.size() > 0) {
        BRepBuilderAPI_MakeWire mkWire;
        
        // add and erase first edge
        mkWire.Add(edge_list.front());
        edge_list.erase(edge_list.begin());

        TopoDS_Wire new_wire = mkWire.Wire();  // current new wire

        // try to connect each edge to the wire, the wire is complete if no more egdes are connectible
        bool found = false;
        do {
            found = false;
            for (std::vector<TopoDS_Edge>::iterator pE = edge_list.begin(); pE != edge_list.end();++pE) {
                mkWire.Add(*pE);
                if (mkWire.Error() != BRepBuilderAPI_DisconnectedWire) {
                    // edge added ==> remove it from list
                    found = true;
                    edge_list.erase(pE);
                    new_wire = mkWire.Wire();
                    break;
                }
            }
        }
        while (found);
        wires.push_back(new_wire);
    }
}