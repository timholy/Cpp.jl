CC=gcc
CFLAGS=-Wall
LDFLAGS=
LINKLIBS=

demo: demo.cpp
	$(CC) $(CFLAGS) -O2 -shared -fPIC demo.cpp $(LDFLAGS) $(LINKLIBS) -o libdemo.$(LIBEXT)

platform=$(shell uname)
ifeq ($(platform),Linux)
        LIBEXT=so
else ifeq ($(platform),Darwin)
        LIBEXT=dylib
else
        LIBEXT=dll
endif

clean:
	-rm libdemo.$(LIBEXT)

.PHONY: \
	demo
