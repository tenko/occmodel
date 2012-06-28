# -*- coding: utf-8 -*-

# OpenGL api & typedefs
from GL cimport *

cpdef glMultMatrixd(m):
    cdef int i
    cdef double cm[16]
    
    for i in range(16):
        cm[i] = m[i]
    
    GLMultMatrixd(cm)

cpdef glLoadMatrixd(m):
    cdef int i
    cdef double cm[16]
    
    for i in range(16):
        cm[i] = m[i]
    
    GLLoadMatrixd(cm)
    
cdef class DisplayList:
    """
    OpenGL display list.
    """
    cdef public GLuint id
    
    def __init__(self):
        self.id = glGenLists(1)
        assert self.id != 0
        
    def __del__(self):
        glDeleteLists(self.id, 1)
    
    def __call__(self):
        glCallList(self.id)
        
    cpdef start(self, bint execute = False):
        if execute:
            glNewList(self.id, GL_COMPILE_AND_EXECUTE)
        else:
            glNewList(self.id, GL_COMPILE)
    
    cpdef end(self):
        glEndList()
    
    cpdef execute(self):
        glCallList(self.id)