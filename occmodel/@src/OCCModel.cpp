// Copyright 2012 by Runar Tenfjord, Tenko as.
// See LICENSE.txt for details on conditions.
#include "OCCModel.h"

char errorMessage[256];

void setErrorMessage(const char *err) {
    strncpy(errorMessage, err, 255);
}

// UTF-8 decoder
// Copyright (c) 2008-2009 Bjoern Hoehrmann <bjoern@hoehrmann.de>
// See http://bjoern.hoehrmann.de/utf-8/decoder/dfa/ for details.

#define UTF8_ACCEPT 0
#define UTF8_REJECT 1

static const unsigned char utf8d[] = {
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 00..1f
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 20..3f
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 40..5f
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // 60..7f
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9, // 80..9f
	7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7, // a0..bf
	8,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, // c0..df
	0xa,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x3,0x4,0x3,0x3, // e0..ef
	0xb,0x6,0x6,0x6,0x5,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8,0x8, // f0..ff
	0x0,0x1,0x2,0x3,0x5,0x8,0x7,0x1,0x1,0x1,0x4,0x6,0x1,0x1,0x1,0x1, // s0..s0
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,0,1,0,1,1,1,1,1,1, // s1..s2
	1,2,1,1,1,1,1,2,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1, // s3..s4
	1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,3,1,1,1,1,1,1, // s5..s6
	1,3,1,1,1,1,1,3,1,3,1,1,1,1,1,1,1,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1, // s7..s8
};

unsigned int decutf8(unsigned int* state, unsigned int* codep, unsigned int byte)
{
	unsigned int type = utf8d[byte];
	*codep = (*state != UTF8_ACCEPT) ?
		(byte & 0x3fu) | (*codep << 6) :
		(0xff >> type) & (byte);
	*state = utf8d[256 + *state*16 + type];
	return *state;
}

int OCCMesh::extractFaceMesh(const TopoDS_Face& face, bool qualityNormals = false)
{
    int vsize = this->vertices.size();
    std::vector<gp_Vec> normals;
    bool reversed = false;
    OCCStruct3f vert;
    OCCStruct3f norm;
    OCCStruct3I tri;
    
    try {
        if(face.IsNull())
            StdFail_NotDone::Raise("Face is Null");
    
        TopLoc_Location loc;
        Handle(Poly_Triangulation) triangulation = BRep_Tool::Triangulation(face, loc);
        
        if(triangulation.IsNull())
            StdFail_NotDone::Raise("No triangulation created");
        
        gp_Trsf tr = loc;
        const TColgp_Array1OfPnt& narr = triangulation->Nodes();
        for (int i = 1; i <= triangulation->NbNodes(); i++)
        {
            Standard_Real x,y,z;
            const gp_Pnt& pnt = narr(i);
            x = pnt.X();
            y = pnt.Y();
            z = pnt.Z();
            tr.Transforms(x,y,z);
            
            vert.x = (float)x;
            vert.y = (float)y;
            vert.z = (float)z;
            this->vertices.push_back(vert);
            
            // ensure we have normals for all vertices
            norm.x = 0.f;
            norm.y = 0.f;
            norm.z = 0.f;
            this->normals.push_back(norm);
            
            if (!qualityNormals)
                normals.push_back(gp_Vec(0.0,0.0,0.0));
        }
        
        if (face.Orientation() == TopAbs_REVERSED)
            reversed = true;
        
        const Poly_Array1OfTriangle& triarr = triangulation->Triangles();
        for (int i = 1; i <= triangulation->NbTriangles(); i++)
        {
            Poly_Triangle pt = triarr(i);
            Standard_Integer n1,n2,n3;
            
            if(reversed)
                pt.Get(n2,n1,n3);
            else
                pt.Get(n1,n2,n3);
            
            // make sure that we don't process invalid triangle
            if (n1 == n2 or n2 == n3 or n3 == n1)
                continue;
                
            // Calculate face normal
            const gp_Pnt& P1 = narr(n1);
            const gp_Pnt& P2 = narr(n2);
            const gp_Pnt& P3 = narr(n3);
            
            gp_Vec V1(P3.X() - P1.X(), P3.Y() - P1.Y(), P3.Z() - P1.Z());
            if (V1.SquareMagnitude() < 1.0e-10)
                // Degenerated triangle
                continue;
            
            gp_Vec V2(P2.X() - P1.X(), P2.Y() - P1.Y(), P2.Z() - P1.Z());
            if (V2.SquareMagnitude() < 1.0e-10)
                // Degenerated triangle
                continue;
            
            gp_Vec normal = V1.Crossed(V2);
            if (normal.SquareMagnitude() < 1.0e-10)
                // Degenerated triangle
                continue;
            
            tri.i = vsize + n1 - 1;
            tri.j = vsize + n2 - 1;
            tri.k = vsize + n3 - 1;
            this->triangles.push_back(tri);
            
            if (!qualityNormals) {
                normals[n1 - 1] = normals[n1 - 1] - normal;
                normals[n2 - 1] = normals[n2 - 1] - normal;
                normals[n3 - 1] = normals[n3 - 1] - normal;
            }
        }
        
        if (qualityNormals) {
            Handle_Geom_Surface surface = BRep_Tool::Surface(face);
            gp_Vec normal;
            for (int i = 0; i < triangulation->NbNodes(); i++)
            {
                vert = this->vertices[vsize + i];
                gp_Pnt vertex(vert.x, vert.y, vert.z);
                GeomAPI_ProjectPointOnSurf SrfProp(vertex, surface);
                Standard_Real fU, fV;
                SrfProp.Parameters(1, fU, fV);

                GeomLProp_SLProps faceprop(surface, fU, fV, 2, gp::Resolution());
                normal = faceprop.Normal();
                
                if (normal.SquareMagnitude() > 1.0e-10)
                    normal.Normalize();
                
                if (reversed) {
                    norm.x = (float)-normal.X();
                    norm.y = (float)-normal.Y();
                    norm.z = (float)-normal.Z();
                } else {
                    norm.x = (float)normal.X();
                    norm.y = (float)normal.Y();
                    norm.z = (float)normal.Z();
                }
                this->normals[vsize + i] = norm;
            }
        } else {
            // Normalize vertex normals
            for (int i = 0; i < triangulation->NbNodes(); i++)
            {
                gp_Vec normal = normals[i];
                if (normal.SquareMagnitude() > 1.0e-10)
                    normal.Normalize();
                
                norm.x = (float)normal.X();
                norm.y = (float)normal.Y();
                norm.z = (float)normal.Z();
                this->normals[vsize + i] = norm;
            }
        }
        
        // extract edge indices from mesh
        std::set<int> seen;
        for (unsigned int i = 0; i < this->edgehash.size(); i++)
            seen.insert(this->edgehash[i]);
        
        int lastSize = this->edgeindices.size();
        TopExp_Explorer ex0, ex1;
        for (ex0.Init(face, TopAbs_WIRE); ex0.More(); ex0.Next()) {
            const TopoDS_Wire& wire = TopoDS::Wire(ex0.Current());
            for (ex1.Init(wire, TopAbs_EDGE); ex1.More(); ex1.Next()) {
                const TopoDS_Edge& edge = TopoDS::Edge(ex1.Current());
                
                // skip degenerated edge
                if (BRep_Tool::Degenerated(edge))
                    continue;
                
                // skip edge if it is a seam
                if (BRep_Tool::IsClosed(edge, face))
                    continue;
                    
                int hash = edge.HashCode(std::numeric_limits<int>::max());
                if (seen.count(hash) == 0) {
                    Handle(Poly_PolygonOnTriangulation) edgepoly = BRep_Tool::PolygonOnTriangulation(edge, triangulation, loc);
                    if (edgepoly.IsNull()) {
                        continue;
                    }
                    seen.insert(hash);
                    this->edgehash.push_back(hash);
                    this->edgeranges.push_back(this->edgeindices.size());
                    
                    const TColStd_Array1OfInteger& edgeind = edgepoly->Nodes();
                    for (int i=edgeind.Lower();i <= edgeind.Upper();i++) {
                        const unsigned int idx = (unsigned int)edgeind(i);
                        this->edgeindices.push_back(vsize + idx - 1);
                    }
                    
                    this->edgeranges.push_back(this->edgeindices.size() - lastSize);
                    lastSize = this->edgeindices.size();
                }
            }
        }
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to mesh object");
        }
        return 0;
    }
    
    return 1;
}