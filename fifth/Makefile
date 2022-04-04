AS := ca65
CC := cl65
C1541 := c1541
X128 := x128
X64 := x64

TIME := $(shell date +%y%m%d%H%M%S)
PROGRAMS := 5th 5mon idump

ifdef CC65_HOME
	AS := $(CC65_HOME)/bin/$(AS)
	CC := $(CC65_HOME)/bin/$(CC)
endif

ifdef VICE_HOME
	C1541 := $(VICE_HOME)/$(C1541)
	X128 := $(VICE_HOME)/$(X128)
	X64 := $(VICE_HOME)/$(X64)
endif

.PHONY: all clean check zap

ASFLAGS = --create-dep $(@:.o=.dep)

all: $(PROGRAMS)

clean:
	rm -f $(PROGRAMS)
	rm -rf *.o 

zap: clean
	rm -rf *.dep

check: $(PROGRAMS)
	$(X64) 5th # -debugcart -limitcycles 10000000 -sounddev dummy -silent -console -8 $+

5th: LDFLAGS += -t c64 -C c64-asm.cfg -u __EXEHDR__
5th: 5th.o

idump: LDFLAGS += -t c64 -C c64-asm.cfg -u __EXEHDR__
idump: idump.o


5mon: LDFLAGS += -t c64 -C 5mon.cfg -u __EXEHDR__
5mon: 5mon.o

-include *.dep
