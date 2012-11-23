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
            if (n1 == n2 || n2 == n3 || n3 == n1)
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

void OCCMesh::optimize() {
    //printf("calcCacheEfficiency1 = %f\n", MeshOptimizer::calcCacheEfficiency(this));
    MeshOptimizer::optimizeIndexOrder(this);
    //printf("calcCacheEfficiency2 = %f\n\n", MeshOptimizer::calcCacheEfficiency(this));
}
        
void OptVertex::updateScore(int cacheIndex)
{
	if(faces.empty())
	{	
		score = 0;
		return;
	}
	
	// The constants used here are coming from the paper
	if(cacheIndex < 0) score = 0;				// Not in cache
	else if(cacheIndex < 3) score = 0.75f;	// Among three most recent vertices
	else score = pow(1.0f - ((cacheIndex - 3) / MeshOptimizer::maxCacheSize), 1.5f);

	score += 2.0f * pow((float)faces.size(), -0.5f);
}

void MeshOptimizer::optimizeIndexOrder(OCCMesh *mesh)
{
	// Implementation of Linear-Speed Vertex Cache Optimisation by Tom Forsyth
	// (see http://home.comcast.net/~tom_forsyth/papers/fast_vert_cache_opt.html)
	const size_t nvertices = mesh->vertices.size();
	const size_t nindices = mesh->triangles.size();
	if(nindices == 0) return;
    
    std::vector<OptVertex> verts(nvertices);
	std::set<OptFace *> faces;
	std::list<OptVertex *> cache;
    
    // Build vertex and triangle structures
	for(unsigned int i = 0; i < nindices; ++i)
	{
		std::set<OptFace *>::iterator itr1 = faces.insert(faces.begin(), new OptFace());
		OptFace *face = (*itr1);
		
        const OCCStruct3I *tri = &mesh->triangles[i];
		face->verts[0] = &verts[tri->i];
		face->verts[1] = &verts[tri->j];
		face->verts[2] = &verts[tri->k];
		face->verts[0]->faces.insert(face);
		face->verts[1]->faces.insert(face);
		face->verts[2]->faces.insert(face);
	}
    for( unsigned int i = 0; i < nvertices; ++i )
	{
		verts[i].index = i;
		verts[i].updateScore( -1 );
	}
    
    // Main loop of algorithm
	unsigned int curIndex = 0;
	
    while( !faces.empty() )
	{
		OptFace *bestFace = 0x0;
		float bestScore = -1.0f;
		
		// Try to find best scoring face in cache
		std::list<OptVertex *>::iterator itr1 = cache.begin();
		while(itr1 != cache.end())
		{
			std::set<OptFace *>::iterator itr2 = (*itr1)->faces.begin();
			while(itr2 != (*itr1)->faces.end())
			{
				if((*itr2)->getScore() > bestScore)
				{
					bestFace = *itr2;
					bestScore = bestFace->getScore();
				}
				++itr2;
			}
			++itr1;
		}
        
        // If that didn't work find it in the complete list of triangles
		if(bestFace == 0x0)
		{
			std::set<OptFace *>::iterator itr2 = faces.begin();
			while(itr2 != faces.end())
			{
				if((*itr2)->getScore() > bestScore)
				{
					bestFace = (*itr2);
					bestScore = bestFace->getScore();
				}
				++itr2;
			}
		}
        
        // Process vertices of best face
        OCCStruct3I *tri = &mesh->triangles[curIndex++];
        tri->i = bestFace->verts[0]->index;
        tri->j = bestFace->verts[1]->index;
        tri->k = bestFace->verts[2]->index;
        
		for( unsigned int i = 0; i < 3; ++i )
		{
			// Move vertex to head of cache
			itr1 = find(cache.begin(), cache.end(), bestFace->verts[i]);
			if(itr1 != cache.end() ) cache.erase( itr1);
			cache.push_front(bestFace->verts[i]);

			// Remove face from vertex lists
			bestFace->verts[i]->faces.erase(bestFace);
		}
        
        // Remove best face
		faces.erase(faces.find(bestFace));
		delete bestFace;
        
        // Update scores of vertices in cache
		unsigned int cacheIndex = 0;
		for(itr1 = cache.begin(); itr1 != cache.end(); ++itr1)
		{
			(*itr1)->updateScore( cacheIndex++ );
		}

		// Trim cache
		for(unsigned int i = cache.size(); i > maxCacheSize; --i)
		{
			cache.pop_back();
		}
    }
    
    // Remap vertices to make access to them as linear as possible
	std::map<unsigned int, unsigned int> mapping;
	unsigned int curVertex = 0;
    
    for(unsigned int i = 0; i < nindices; ++i)
	{
        OCCStruct3I *tri = &mesh->triangles[i];
        
        std::map<unsigned int, unsigned int>::iterator itr1 = mapping.find(tri->i);
		if(itr1 == mapping.end())
		{
			mapping[tri->i] = curVertex;
			tri->i = curVertex++;
		}
		else
		{
			tri->i = itr1->second;
		}
        
        std::map<unsigned int, unsigned int>::iterator itr2 = mapping.find(tri->j);
		if(itr2 == mapping.end())
		{
			mapping[tri->j] = curVertex;
			tri->j = curVertex++;
		}
		else
		{
			tri->j = itr2->second;
		}
        
        std::map<unsigned int, unsigned int>::iterator itr3 = mapping.find(tri->k);
		if(itr3 == mapping.end())
		{
			mapping[tri->k] = curVertex;
			tri->k = curVertex++;
		}
		else
		{
			tri->k = itr3->second;
		}
    }
    
    std::vector<OCCStruct3f> oldVertices(mesh->vertices.begin(),  mesh->vertices.end());
    std::vector<OCCStruct3f> oldNormals(mesh->normals.begin(), mesh->normals.end());    
    for(std::map<unsigned int, unsigned int>::iterator itr1 = mapping.begin();
        itr1 != mapping.end(); ++itr1 )
	{
		mesh->vertices[itr1->second] = oldVertices[itr1->first];
		mesh->normals[itr1->second] = oldNormals[itr1->first];
	}
    
    for(unsigned int i = 0; i < mesh->edgeindices.size(); ++i)
	{
        mesh->edgeindices[i] = mapping[mesh->edgeindices[i]];
    }
}

float MeshOptimizer::calcCacheEfficiency(OCCMesh *mesh,
                                         const unsigned int cacheSize)
{	
	// Measure efficiency of index array regarding post-transform vertex cache
	unsigned int misses = 0;
    const unsigned int nindices = mesh->triangles.size();
	std::list<unsigned int> testCache;
    for(unsigned int i = 0; i < nindices; ++i)
	{
        OCCStruct3I *tri = &mesh->triangles[i];
		if(std::find(testCache.begin(), testCache.end(), tri->i) == testCache.end())
		{
			testCache.push_back(tri->i);
			if(testCache.size() > cacheSize) testCache.erase(testCache.begin());
			++misses;
		}
        if(std::find(testCache.begin(), testCache.end(), tri->j) == testCache.end())
		{
			testCache.push_back(tri->j);
			if(testCache.size() > cacheSize) testCache.erase(testCache.begin());
			++misses;
		}
        if(std::find(testCache.begin(), testCache.end(), tri->k) == testCache.end())
		{
			testCache.push_back(tri->k);
			if(testCache.size() > cacheSize) testCache.erase(testCache.begin());
			++misses;
		}
    }
    
    // Average transform to vertex ratio (ATVR)
	// 1.0 is theoretical optimum, meaning that each vertex is just transformed exactly one time
	float atvr = (float)(3*nindices + misses) / (3*nindices);
	return atvr;
}