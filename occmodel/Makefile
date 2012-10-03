#
# File:  Makefile (for library)
#
PYTHON=python2
CC=g++
CFLAGS=-Wall -fPIC -O2 -frtti -fexceptions -Isrc -I/usr/include/oce
LIB=liboccmodel.a
    
LIBSRC = $(wildcard @src/*.cpp)

LIBOBJ=$(LIBSRC:.cpp=.o)

.PHONY: pylib docs test tests install clean
    
$(LIB): $(LIBOBJ)
	@echo lib Makefile - archiving $(LIB)
	@$(AR) r $(LIB) $(LIBOBJ)

.cpp.o:
	@echo lib Makefile - compiling $<
	@$(CC) $(CFLAGS) -c $< -o $@

pylib: $(LIB)
	@echo lib Makefile - building python extension
	$(PYTHON) setup_build.py build_ext --inplace

docs: pylib
	@echo lib Makefile - building documentation
	@cd @docs ; $(PYTHON) ../setup_docs.py build_sphinx
	@cp -rf @docs/build/sphinx/html/* @docs/html/
    
test: pylib
	@echo lib Makefile - running test file
	$(PYTHON) test.py
    
tests: pylib
	@echo lib Makefile - running test suite
	@cd @tests ; $(PYTHON) runAll.py

install: pylib
	@cp occmodel.so ~/.local/lib/python2.7/site-packages/
    
clean:
	-rm $(LIBOBJ)
	-rm $(LIB)
	-rm -rf build
	-rm occmodel.so