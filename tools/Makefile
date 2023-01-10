AS := ca65
CC := cl65
C1541 := c1541
X128 := x128

PROGRAMS := kmon64 kmon128 pip64 pip128 patch64 patch128 mtop sjload
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

kmon64: kmon64.o
	$(CC) $(LDFLAGS) -t c64 -C c64.cfg -u __EXEHDR__ -o kmon64 kmon64.o
kmon64.o: kmon.s
	$(AS) $(ASFLAGS) -t c64 -o kmon64.o kmon.s

kmon128: kmon128.o
	$(CC) $(LDFLAGS) -t c128 -C c128.cfg -o kmon128 kmon128.o
kmon128.o: kmon.s
	$(AS) $(ASFLAGS) -t c128 -o kmon128.o kmon.s

kmon16: kmon16.o
	$(CC) $(LDFLAGS) -t c16 -C c16.cfg -o kmon16 kmon16.o
kmon16.o: kmon.s
	$(AS) $(ASFLAGS) -t c16 -o kmon16.o kmon.s

pip64: pip64.o
	$(CC) $(LDFLAGS) -t c64 -C c64.cfg -u __EXEHDR__ -o pip64 pip64.o
pip64.o: pip.s
	$(AS) $(ASFLAGS) -t c64 -o pip64.o pip.s

pip128: pip128.o
	$(CC) $(LDFLAGS) -t c128 -C c128.cfg -o pip128 pip128.o
pip128.o: pip.s
	$(AS) $(ASFLAGS) -t c128 -o pip128.o pip.s

patch64: LDFLAGS += -t c64 -C c64.cfg -u __EXEHDR__ 
patch64: patch64.o

patch128: LDFLAGS += -t c128  
patch128: patch128.o

mtop: LDFLAGS += -t c64 -C c64.cfg -u __EXEHDR__
mtop: mtop.o

sjload: sjload.o
	$(CC) $(LDFLAGS) -t c64 -C sjload.cfg -o sjload sjload.o 
sjload.o: sjload.s
	$(AS) $(ASFLAGS) -t c64 -o sjload.o sjload.s

-include *.dep
