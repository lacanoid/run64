AS := ca65
CC := cl65
C1541 := c1541
X128 := x128

PROGRAMS := kmon pip patch64 patch128 mtop
INCLUDES := ..

ifdef CC65_HOME
	AS := $(CC65_HOME)/bin/$(AS)
	CC := $(CC65_HOME)/bin/$(CC)
endif

.PHONY: all clean check zap

ASFLAGS = -I$(INCLUDES) --create-dep $(@:.o=.dep)

all: $(PROGRAMS)

clean:
	rm -f $(PROGRAMS)
	rm -rf *.o

zap: clean
	rm -rf *.dep

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
