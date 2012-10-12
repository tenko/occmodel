# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#
# GLUT api & typedefs
from GLUT cimport *

cdef int GLUT_WHEEL_UP = 3
cdef int GLUT_WHEEL_DOWN = 4

cpdef glutInit(args):
    cdef int argc = len(args)
    cdef char **c_argv = <char**>malloc(sizeof(char*) * argc) 
    if c_argv is NULL: 
        raise MemoryError() 
    try: 
        for idx, s in enumerate(args): 
           c_argv[idx] = s 
        GLUTInit(&argc, c_argv) 
    finally: 
        free(c_argv)

# Menu stuff

cdef object menu_ptr

cdef call_menu(int menu) with gil:
    try:
        menu_ptr(menu)
    except:
        import sys
        import traceback
        traceback.print_exc(file=sys.stdout)
        
cpdef int glutCreateMenu(pycb):
    global menu_ptr
    if not menu_ptr is None:
        raise ValueError('callback already set')
    menu_ptr = pycb
    return GLUTCreateMenu(<void *>call_menu)

# Window-specific callback functions
cdef object timer_ptr
cdef call_timer(int value) with gil:
    timer_ptr(value)

cpdef glutTimerFunc(unsigned int time, pycb, int value):
    global timer_ptr
    if not timer_ptr is None:
        raise ValueError('callback already set')
    timer_ptr = pycb
    GLUTTimerFunc(time, <void *>call_timer, value)
    
cdef object idle_ptr
cdef call_idle() with gil:
    idle_ptr()

cpdef glutIdleFunc(pycb):
    global idle_ptr
    if not idle_ptr is None:
        raise ValueError('callback already set')
    idle_ptr = pycb
    GLUTIdleFunc(<void *>call_idle)
    
cdef object keyboard_ptr
cdef call_keyboard(unsigned char c, int x, int y) with gil:
    keyboard_ptr(c, x, y)

cpdef glutKeyboardFunc(pycb):
    global keyboard_ptr
    if not keyboard_ptr is None:
        raise ValueError('callback already set')
    keyboard_ptr = pycb
    GLUTKeyboardFunc(<void *>call_keyboard)
    
cdef object reshape_ptr
cdef call_reshape(int w, int h) with gil:
    reshape_ptr(w,h)

cpdef glutReshapeFunc(pycb):
    global reshape_ptr
    if not reshape_ptr is None:
        raise ValueError('callback already set')
    reshape_ptr = pycb
    GLUTReshapeFunc(<void *>call_reshape)

cdef object display_ptr
cdef call_display() with gil:
    display_ptr()

cpdef glutDisplayFunc(pycb):
    global display_ptr
    if not display_ptr is None:
        raise ValueError('callback already set')
    display_ptr = pycb
    GLUTDisplayFunc(<void *>call_display)
    
cdef object mouse_ptr
cdef call_mouse(int button, int state, int x, int y) with gil:
    mouse_ptr(button, state, x, y)

cpdef glutMouseFunc(pycb):
    global mouse_ptr
    if not mouse_ptr is None:
        raise ValueError('callback already set')
    mouse_ptr = pycb
    GLUTMouseFunc(<void *>call_mouse)
    
cdef object motion_ptr
cdef call_motion(int x, int y) with gil:
    motion_ptr(x,y)

cpdef glutMotionFunc(pycb):
    global motion_ptr
    if not motion_ptr is None:
        raise ValueError('callback already set')
    motion_ptr = pycb
    GLUTMotionFunc(<void *>call_motion)