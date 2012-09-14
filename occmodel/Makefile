#
# File:  Makefile (for library)
#
CC=g++
CFLAGS=-Wall -fPIC -O2 -frtti -fexceptions -Isrc -I/usr/include/oce
LIB=liboccmodel.a
    
LIBSRC = @src/OCCModel.cpp @src/OCCEdge.cpp @src/OCCWire.cpp @src/OCCFace.cpp @src/OCCSolid.cpp
 
LIBOBJ=$(LIBSRC:.cpp=.o)

$(LIB): $(LIBOBJ)
	@echo lib Makefile - archiving $(LIB)
	@$(AR) r $(LIB) $(LIBOBJ)

.cpp.o:
	@echo lib Makefile - compiling $<
	@$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm $(LIBOBJ)
	rm $(LIB)