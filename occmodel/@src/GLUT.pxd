cdef extern from "GL/glut.h":
    # GLUT API macro definitions -- the special key codes:
    int GLUT_KEY_F1
    int GLUT_KEY_F2
    int GLUT_KEY_F3
    int GLUT_KEY_F4
    int GLUT_KEY_F5
    int GLUT_KEY_F6
    int GLUT_KEY_F7
    int GLUT_KEY_F8
    int GLUT_KEY_F9
    int GLUT_KEY_F10
    int GLUT_KEY_F11
    int GLUT_KEY_F12
    int GLUT_KEY_LEFT
    int GLUT_KEY_UP
    int GLUT_KEY_RIGHT
    int GLUT_KEY_DOWN
    int GLUT_KEY_PAGE_UP
    int GLUT_KEY_PAGE_DOWN
    int GLUT_KEY_HOME
    int GLUT_KEY_END
    int GLUT_KEY_INSERT

    # GLUT API macro definitions -- mouse state definitions
    int GLUT_LEFT_BUTTON
    int GLUT_MIDDLE_BUTTON
    int GLUT_RIGHT_BUTTON
    int GLUT_DOWN
    int GLUT_UP
    int GLUT_LEFT
    int GLUT_ENTERED

    # GLUT API macro definitions -- the display mode definitions
    int GLUT_RGB
    int GLUT_RGBA
    int GLUT_INDEX
    int GLUT_SINGLE
    int GLUT_DOUBLE
    int GLUT_ACCUM
    int GLUT_ALPHA
    int GLUT_DEPTH
    int GLUT_STENCIL
    int GLUT_MULTISAMPLE
    int GLUT_STEREO
    int GLUT_LUMINANCE

    # GLUT API macro definitions -- windows and menu related definitions
    int GLUT_MENU_NOT_IN_USE 
    int GLUT_MENU_IN_USE
    int GLUT_NOT_VISIBLE
    int GLUT_VISIBLE
    int GLUT_HIDDEN
    int GLUT_FULLY_RETAINED
    int GLUT_PARTIALLY_RETAINED
    int GLUT_FULLY_COVERED
    
    # GLUT API macro definitions -- the glutGet parameters
    int GLUT_WINDOW_X
    int GLUT_WINDOW_Y
    int GLUT_WINDOW_WIDTH
    int GLUT_WINDOW_HEIGHT
    int GLUT_WINDOW_BUFFER_SIZE
    int GLUT_WINDOW_STENCIL_SIZE
    int GLUT_WINDOW_DEPTH_SIZE
    int GLUT_WINDOW_RED_SIZE
    int GLUT_WINDOW_GREEN_SIZE
    int GLUT_WINDOW_BLUE_SIZE
    int GLUT_WINDOW_ALPHA_SIZE
    int GLUT_WINDOW_ACCUM_RED_SIZE
    int GLUT_WINDOW_ACCUM_GREEN_SIZE
    int GLUT_WINDOW_ACCUM_BLUE_SIZE
    int GLUT_WINDOW_ACCUM_ALPHA_SIZE
    int GLUT_WINDOW_DOUBLEBUFFER
    int GLUT_WINDOW_RGBA
    int GLUT_WINDOW_PARENT
    int GLUT_WINDOW_NUM_CHILDREN
    int GLUT_WINDOW_COLORMAP_SIZE
    int GLUT_WINDOW_NUM_SAMPLES
    int GLUT_WINDOW_STEREO
    int GLUT_WINDOW_CURSOR

    int GLUT_SCREEN_WIDTH
    int GLUT_SCREEN_HEIGHT
    int GLUT_SCREEN_WIDTH_MM
    int GLUT_SCREEN_HEIGHT_MM
    int GLUT_MENU_NUM_ITEMS
    int GLUT_DISPLAY_MODE_POSSIBLE
    int GLUT_INIT_WINDOW_X
    int GLUT_INIT_WINDOW_Y
    int GLUT_INIT_WINDOW_WIDTH
    int GLUT_INIT_WINDOW_HEIGHT
    int GLUT_INIT_DISPLAY_MODE
    int GLUT_ELAPSED_TIME
    int GLUT_WINDOW_FORMAT_ID

    # GLUT API macro definitions -- the glutDeviceGet parameters
    int GLUT_HAS_KEYBOARD
    int GLUT_HAS_MOUSE
    int GLUT_HAS_SPACEBALL
    int GLUT_HAS_DIAL_AND_BUTTON_BOX
    int GLUT_HAS_TABLET
    int GLUT_NUM_MOUSE_BUTTONS
    int GLUT_NUM_SPACEBALL_BUTTONS
    int GLUT_NUM_BUTTON_BOX_BUTTONS
    int GLUT_NUM_DIALS
    int GLUT_NUM_TABLET_BUTTONS
    int GLUT_DEVICE_IGNORE_KEY_REPEAT
    int GLUT_DEVICE_KEY_REPEAT
    int GLUT_HAS_JOYSTICK
    int GLUT_OWNS_JOYSTICK
    int GLUT_JOYSTICK_BUTTONS
    int GLUT_JOYSTICK_AXES
    int GLUT_JOYSTICK_POLL_RATE

    # GLUT API macro definitions -- the glutLayerGet parameters
    int GLUT_OVERLAY_POSSIBLE
    int GLUT_LAYER_IN_USE
    int GLUT_HAS_OVERLAY
    int GLUT_TRANSPARENT_INDEX
    int GLUT_NORMAL_DAMAGED
    int GLUT_OVERLAY_DAMAGED

    # GLUT API macro definitions -- the glutVideoResizeGet parameters
    int GLUT_VIDEO_RESIZE_POSSIBLE
    int GLUT_VIDEO_RESIZE_IN_USE
    int GLUT_VIDEO_RESIZE_X_DELTA
    int GLUT_VIDEO_RESIZE_Y_DELTA
    int GLUT_VIDEO_RESIZE_WIDTH_DELTA
    int GLUT_VIDEO_RESIZE_HEIGHT_DELTA
    int GLUT_VIDEO_RESIZE_X
    int GLUT_VIDEO_RESIZE_Y
    int GLUT_VIDEO_RESIZE_WIDTH
    int GLUT_VIDEO_RESIZE_HEIGHT

    # GLUT API macro definitions -- the glutUseLayer parameters
    int GLUT_NORMAL
    int GLUT_OVERLAY

    # GLUT API macro definitions -- the glutGetModifiers parameters
    int GLUT_ACTIVE_SHIFT
    int GLUT_ACTIVE_CTRL
    int GLUT_ACTIVE_ALT

    # GLUT API macro definitions -- the glutSetCursor parameters
    int GLUT_CURSOR_RIGHT_ARROW
    int GLUT_CURSOR_LEFT_ARROW
    int GLUT_CURSOR_INFO
    int GLUT_CURSOR_DESTROY
    int GLUT_CURSOR_HELP
    int GLUT_CURSOR_CYCLE
    int GLUT_CURSOR_SPRAY
    int GLUT_CURSOR_WAIT
    int GLUT_CURSOR_TEXT
    int GLUT_CURSOR_CROSSHAIR
    int GLUT_CURSOR_UP_DOWN
    int GLUT_CURSOR_LEFT_RIGHT
    int GLUT_CURSOR_TOP_SIDE
    int GLUT_CURSOR_BOTTOM_SIDE
    int GLUT_CURSOR_LEFT_SIDE
    int GLUT_CURSOR_RIGHT_SIDE
    int GLUT_CURSOR_TOP_LEFT_CORNER
    int GLUT_CURSOR_TOP_RIGHT_CORNER
    int GLUT_CURSOR_BOTTOM_RIGHT_CORNER
    int GLUT_CURSOR_BOTTOM_LEFT_CORNER
    int GLUT_CURSOR_INHERIT
    int GLUT_CURSOR_NONE
    int GLUT_CURSOR_FULL_CROSSHAIR

    # GLUT API macro definitions -- RGB color component specification definitions
    int GLUT_RED
    int GLUT_GREEN
    int GLUT_BLUE

    # GLUT API macro definitions -- additional keyboard and joystick definitions
    int GLUT_KEY_REPEAT_OFF
    int GLUT_KEY_REPEAT_ON
    int GLUT_KEY_REPEAT_DEFAULT

    int GLUT_JOYSTICK_BUTTON_A
    int GLUT_JOYSTICK_BUTTON_B
    int GLUT_JOYSTICK_BUTTON_C
    int GLUT_JOYSTICK_BUTTON_D

    # GLUT API macro definitions -- game mode definitions
    int GLUT_GAME_MODE_ACTIVE
    int GLUT_GAME_MODE_POSSIBLE
    int GLUT_GAME_MODE_WIDTH
    int GLUT_GAME_MODE_HEIGHT
    int GLUT_GAME_MODE_PIXEL_DEPTH
    int GLUT_GAME_MODE_REFRESH_RATE
    int GLUT_GAME_MODE_DISPLAY_CHANGED
    
    # Initialization functions
    void GLUTInit "glutInit"(int *argc, char **argv)
    void glutInitWindowPosition(int x, int y)
    void glutInitWindowSize(int width, int height)
    void glutInitDisplayMode(unsigned int displayMode)
    void glutInitDisplayString(char *displayMode)
    
    # Process loop function
    void glutMainLoop() nogil
    
    # Window management functions
    int glutCreateWindow(char *title)
    int glutCreateSubWindow(int window, int x, int y, int width, int height)
    void glutDestroyWindow(int window)
    void glutSetWindow(int window)
    int glutGetWindow()
    void glutSetWindowTitle(char *title)
    void glutSetIconTitle(char *title)
    void glutReshapeWindow(int width, int height)
    void glutPositionWindow(int x, int y)
    void glutShowWindow()
    void glutHideWindow()
    void glutIconifyWindow()
    void glutPushWindow()
    void glutPopWindow()
    void glutFullScreen()
    
    # Display-connected functions
    void glutPostWindowRedisplay(int window)
    void glutPostRedisplay()
    void glutSwapBuffers()
    
    # Mouse cursor functions
    void glutWarpPointer(int x, int y)
    void glutSetCursor(int cursor)
    
    # Overlay stuff
    void glutEstablishOverlay()
    void glutRemoveOverlay()
    void glutUseLayer(int layer)
    void glutPostOverlayRedisplay()
    void glutPostWindowOverlayRedisplay(int window)
    void glutShowOverlay()
    void glutHideOverlay()
    
    # Menu stuff
    int GLUTCreateMenu "glutCreateMenu"(void *callback)
    void glutDestroyMenu(int menu)
    int glutGetMenu()
    void glutSetMenu(int menu)
    void glutAddMenuEntry(char *label, int value)
    void glutAddSubMenu(char *label, int subMenu)
    void glutChangeToMenuEntry(int item, char *label, int value)
    void glutChangeToSubMenu(int item, char *label, int value)
    void glutRemoveMenuItem(int item)
    void glutAttachMenu(int button)
    void glutDetachMenu(int button)

    # Global callback functions
    void GLUTTimerFunc "glutTimerFunc"(unsigned int time, void *callback, int value)
    void GLUTIdleFunc "glutIdleFunc"(void *callback)
    
    # Window-specific callback functions
    void GLUTKeyboardFunc "glutKeyboardFunc"(void *callback)
    void GLUTSpecialFunc "glutSpecialFunc"(void *callback)
    void GLUTReshapeFunc "glutReshapeFunc"(void *callback)
    void GLUTVisibilityFunc "glutVisibilityFunc"(void *callback)
    void GLUTDisplayFunc "glutDisplayFunc"(void *callback)
    void GLUTMouseFunc "glutMouseFunc"(void *callback)
    void GLUTMotionFunc "glutMotionFunc"(void *callback)
    void GLUTPassiveMotionFunc "glutPassiveMotionFunc"(void *callback)
    void GLUTEntryFunc "glutEntryFunc"(void *callback)

    void glutKeyboardUpFunc(void *callback)
    void glutSpecialUpFunc(void *callback)
    void glutJoystickFunc(void *callback, int pollInterval )
    void glutMenuStateFunc(void *callback)
    void glutMenuStatusFunc(void *callback)
    void glutOverlayDisplayFunc(void *callback)
    void glutWindowStatusFunc(void *callback)

    void glutSpaceballMotionFunc(void *callback)
    void glutSpaceballRotateFunc(void *callback)
    void glutSpaceballButtonFunc(void *callback)
    void glutButtonBoxFunc(void *callback)
    void glutDialsFunc(void *callback)
    void glutTabletMotionFunc(void *callback)
    void glutTabletButtonFunc(void *callback)
    
    # State setting and retrieval functions
    int glutGet(int query)
    int glutDeviceGet(int query)
    int glutGetModifiers()
    int glutLayerGet(int query)

    # Font stuff
    void glutBitmapCharacter(void *font, int character)
    int glutBitmapWidth(void *font, int character)
    void glutStrokeCharacter(void *font, int character)
    int glutStrokeWidth(void *font, int character)
    int glutBitmapLength(void *font, unsigned char *string)
    int glutStrokeLength(void *font, unsigned char *string)