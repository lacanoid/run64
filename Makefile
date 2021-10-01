AS := ca65
CC := cl65
C1541 := c1541
X128 := x128

ifdef CC65_HOME
	AS := $(CC65_HOME)/bin/$(AS)
	CC := $(CC65_HOME)/bin/$(CC)
endif

ifdef VICE_HOME
	C1541 := $(VICE_HOME)/$(C1541)
	X128 := $(VICE_HOME)/$(X128)
endif

.PHONY: all clean check zap

ASFLAGS = --create-dep $(@:.o=.dep)

all: bootsect.128 bootsect2.128 hello
clean:
	rm -rf *.o test.d64 test.d71 test.d81 bootsect.128 bootsect2.128 hello raster
zap: clean
	rm -rf *.dep

check: test.d64
	$(X128) -debugcart -limitcycles 10000000 -sounddev dummy -silent -console -8 $+

test.d64: raster hello bootsect2.128 bootsect.128 Makefile
	$(C1541) -format test,xx d64 test.d64 \
		-write hello \
		-write raster \
		-write install \
		-bwrite bootsect.128 1 0 \
		-bwrite bootsect2.128 1 1

test.d71: raster hello bootsect2.128 bootsect.128 Makefile
	$(C1541) -format test,xx d71 test.d71 \
		-write hello \
		-write raster \
		-write install \
		-write smon \
		-bwrite bootsect.128 1 0 \
		-bwrite bootsect2.128 1 1

test.d81: raster hello bootsect2.128 bootsect.128 Makefile
	$(C1541) -format test,xx d81 test.d81 \
		-write hello \
		-write raster \
		-write install \
		-bwrite bootsect.128 1 0 \
		-bwrite bootsect2.128 1 1

bootsect.128: LDFLAGS += -C linker.cfg
bootsect.128: bootsect.128.o bootsect2.128.o autostart64.o

bootsect2.128: LDFLAGS += -C linker.cfg
bootsect2.128: bootsect.128.o bootsect2.128.o autostart64.o

hello: LDFLAGS += -t c64 -C c64-asm.cfg -u __EXEHDR__
hello: hello.o

raster: LDFLAGS += -t c64 -C c64-asm.cfg -u __EXEHDR__
raster: raster.o

-include *.dep
