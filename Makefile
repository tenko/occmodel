#
# File:  Makefile (for library)
#
# The variables 'PYTHON' and 'PYVER' can be modified by
# passing parameters to make: make PYTHON=python PYVER=2.7
#
PYTHON=python3
PYVER=3.5

CC=g++
CFLAGS=-Wall -fPIC -O2 -frtti -fexceptions -Isrc -I/mingw64/include/oce
LIB=occmodel/liboccmodel.a
    
LIBSRC = $(wildcard occmodel/@src/*.cpp)

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
	$(PYTHON) setup_build.py build_ext --inplace --force
    
docs: pylib
	@echo lib Makefile - building documentation
	@cd occmodel/@docs ; $(PYTHON) ../../setup_docs.py build_sphinx
	@cp -rf occmodel/@docs/build/sphinx/html/* occmodel/@docs/html/
    
test: pylib
	@echo lib Makefile - running test file
	$(PYTHON) occmodel/test.py
    
tests: pylib
	@echo lib Makefile - running test suite
	@cd occmodel/@tests ; $(PYTHON) runAll.py

install: pylib
	@cp occmodel.so ~/.local/lib/python$(PYVER)/site-packages/
	@cp occmodelviewer.so ~/.local/lib/python$(PYVER)/site-packages/

sdist: clean
	@echo lib Makefile - creating source distribution
	$(PYTHON) setup_build.py sdist --formats=gztar,zip
    
clean:
	-rm $(LIBOBJ)
	-rm $(LIB)
	-rm -rf build dist
	-rm -rf occmodel/@docs/build
	-rm MANIFEST occmodel/@src/Config.pxi
	-rm occmodel.dll occmodel.so occmodel/occmodel.cpp
	-rm occmodelviewer.dll occmodelviewer.so occmodel/occmodelviewer.c
	-find occmodel -iname '*.so' -exec rm {} \;
	-find occmodel -iname '*.pyc' -exec rm {} \;
	-find occmodel -iname '*.pyo' -exec rm {} \;
	-find occmodel -iname '*.pyd' -exec rm {} \;
