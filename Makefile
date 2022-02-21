AS := ca65
CC := cl65
C1541 := c1541
X128 := x128

TIME := $(shell date +%y%m%d%H%M%S)
VOLNAME := run64 ${TIME},sy
PROGRAMS := kmon pip patch64 patch128

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

all: bootsect.128 autostart64.128 disks

clean:
	rm $(PROGRAMS)
	rm -rf *.o run64.d64 run64.d71 run64.d81 bootsect.128 autostart64.128
zap: clean
	rm -rf *.dep

check: run64.d64
	$(X128) -debugcart -limitcycles 10000000 -sounddev dummy -silent -console -8 $+

disks: run64.d64 run64.d71 run64.d81

run64.d64: ${PROGRAMS} autostart64.128 bootsect.128 Makefile
	$(C1541) -format "${VOLNAME}" d64 run64.d64
	./install.sh run64.d64

run64.d71: ${PROGRAMS} autostart64.128 bootsect.128 Makefile
	$(C1541) -format "${VOLNAME}" d71 run64.d71
	./install.sh run64.d71

run64.d81: ${PROGRAMS} autostart64.128 bootsect.128 Makefile
	$(C1541) -format "${VOLNAME}" d81 run64.d81
	./install.sh run64.d81

bootsect.128: LDFLAGS += -C linker.cfg
bootsect.128: bootsect.128.o autostart64.128.o autostart64.o

autostart64.128: LDFLAGS += -C linker.cfg
autostart64.128: bootsect.128.o autostart64.128.o autostart64.o

kmon: LDFLAGS += -t c64 -C kmon.cfg -u __EXEHDR__
kmon: kmon.o

pip: LDFLAGS += -t c64 -C c64-asm.cfg -u __EXEHDR__ 
pip: pip.o

patch64: LDFLAGS += -t c64 -C c64-asm.cfg -u __EXEHDR__ 
patch64: patch64.o

patch128: LDFLAGS += -t c128  
patch128: patch128.o

raster: LDFLAGS += -t c64 -C c64-asm.cfg -u __EXEHDR__
raster: raster.o

mtop: LDFLAGS += -t c64 -C c64-asm.cfg -u __EXEHDR__
mtop: mtop.o

-include *.dep
