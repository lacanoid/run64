AS := ca65
CC := cl65
C1541 := c1541
X128 := x128

TIME := $(shell date +%y%m%d%H%M%S)
VOLNAME := run64 ${TIME},sy
PROGRAMS := vdc64 vdc128 raster
INCLUDES := ..

ifdef CC65_HOME
	AS := $(CC65_HOME)/bin/$(AS)
	CC := $(CC65_HOME)/bin/$(CC)
endif

ifdef VICE_HOME
	C1541 := $(VICE_HOME)/$(C1541)
	X128 := $(VICE_HOME)/$(X128)
endif

.PHONY: all clean check zap

ASFLAGS = -I$(INCLUDES) --create-dep $(@:.o=.dep)

all: $(PROGRAMS)

clean:
	rm -f $(PROGRAMS)
	rm -rf *.o 

zap: clean
	rm -rf *.dep

vdc64: LDFLAGS += -t c64 -C c64-asm.cfg -u __EXEHDR__
vdc64: vdc64.o

vdc128: LDFLAGS += -t c128  
vdc128: vdc128.o

raster: LDFLAGS += -t c64 -C c64-asm.cfg -u __EXEHDR__
raster: raster.o

-include *.dep
