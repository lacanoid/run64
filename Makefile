AS := ca65
CC := cl65
C1541 := c1541
X128 := x128

TIME := $(shell date +%y%m%d%H%M%S)
VOLNAME := run64 ${TIME},sy
PROGRAMS := kmon pip patch64 patch128 mtop

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

all: disks

clean:
	rm -f $(PROGRAMS)
	rm -rf *.o run64.d64 run64.d71 run64.d81

zap: clean
	rm -rf *.dep

check: run64.d64
	$(X128) -debugcart -limitcycles 10000000 -sounddev dummy -silent -console -8 $+

disks: fortune run64.d71 run64.d81

fortune:
	fortune > issue,s

run64.d64: ${PROGRAMS} Makefile
	$(C1541) -format "${VOLNAME}" d64 run64.d64
	./install.sh run64.d64

run64.d71: ${PROGRAMS} Makefile
	$(C1541) -format "${VOLNAME}" d71 run64.d71
	./install.sh run64.d71

run64.d81: ${PROGRAMS} Makefile
	$(C1541) -format "${VOLNAME}" d81 run64.d81
	./install.sh run64.d81

kmon: LDFLAGS += -t c64 -C kmon.cfg -u __EXEHDR__
kmon: kmon.o

pip: LDFLAGS += -t c64 -C c64-asm.cfg -u __EXEHDR__ 
pip: pip.o

patch64: LDFLAGS += -t c64 -C c64-asm.cfg -u __EXEHDR__ 
patch64: patch64.o

patch128: LDFLAGS += -t c128  
patch128: patch128.o

mtop: LDFLAGS += -t c64 -C c64-asm.cfg -u __EXEHDR__
mtop: mtop.o

-include *.dep
