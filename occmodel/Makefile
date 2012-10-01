#
# File:  Makefile (for library)
#
PYTHON=python2
CC=g++
CFLAGS=-Wall -fPIC -O2 -frtti -fexceptions -Isrc -I/usr/include/oce
LIB=liboccmodel.a
    
LIBSRC = $(wildcard @src/*.cpp)

LIBOBJ=$(LIBSRC:.cpp=.o)

.PHONY: pylib test tests clean
    
$(LIB): $(LIBOBJ)
	@echo lib Makefile - archiving $(LIB)
	@$(AR) r $(LIB) $(LIBOBJ)

.cpp.o:
	@echo lib Makefile - compiling $<
	@$(CC) $(CFLAGS) -c $< -o $@

pylib:
	@echo lib Makefile - building python extension
	$(PYTHON) setup_build.py

test:
	@echo lib Makefile - running test file
	$(PYTHON) test.py
    
tests:
	@echo lib Makefile - running test suite
	@cd @tests ; $(PYTHON) runAll.py
    
clean:
	rm $(LIBOBJ)
	rm $(LIB)
