// Gmsh - Copyright (C) 1997-2011 C. Geuzaine, J.-F. Remacle
//
// See the LICENSE.txt file for license information. Please report all
// bugs and problems to <gmsh@geuz.org>.
#include "OCCModel.h"

int OCCMesh::extractFaceMesh(const TopoDS_Face& face, bool qualityNormals = false)
{
    int vsize = this->vertices.size();
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
            this->vertices.push_back(dtmp);
            
            // ensure we have normals for all vertices
            dtmp.clear();
            dtmp.push_back(0.);
            dtmp.push_back(0.);
            dtmp.push_back(0.);
            this->normals.push_back(dtmp);
            
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
            this->triangles.push_back(itmp);
            
            if (!qualityNormals) {
                normals[n1 - 1] = normals[n1 - 1] - normal;
                normals[n2 - 1] = normals[n2 - 1] - normal;
                normals[n3 - 1] = normals[n3 - 1] - normal;
            }
        }
        
        if (qualityNormals) {
            gp_Vec normal;
            for (int i = 0; i < tri->NbNodes(); i++)
            {
                Handle_Geom_Surface surface = BRep_Tool::Surface(face);
                
                gp_Pnt vertex(this->vertices[vsize + i][0],
                              this->vertices[vsize + i][1],
                              this->vertices[vsize + i][2]);
                GeomAPI_ProjectPointOnSurf SrfProp(vertex, surface);
                Standard_Real fU, fV; SrfProp.Parameters(1, fU, fV);

                GeomLProp_SLProps faceprop(surface, fU, fV, 2, gp::Resolution());
                normal = faceprop.Normal();
                
                if (normal.SquareMagnitude() > 1.0e-10)
                    normal.Normalize();
                
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
                this->normals[vsize + i] = dtmp;
            }
        } else {
            // Normalize vertex normals
            for (int i = 0; i < tri->NbNodes(); i++)
            {
                gp_Vec normal = normals[i];
                if (normal.SquareMagnitude() > 1.0e-10)
                    normal.Normalize();
                dtmp.clear();
                dtmp.push_back(normal.X());
                dtmp.push_back(normal.Y());
                dtmp.push_back(normal.Z());
                this->normals[vsize + i] = dtmp;
            }
        }
        
    } catch(Standard_Failure &err) {
        //Handle_Standard_Failure e = Standard_Failure::Caught();
        //printf("ERROR: %s\n", e->GetMessageString());
        return 1;
    }
    
    return 0;
}