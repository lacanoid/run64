AS := ca65
CC := cl65
C1541 := c1541
X128 := x128

PROGRAMS := kmon kmon.128 pip pip.128 patch64 patch128 mtop
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

kmon: kmon.o
	$(CC) $(LDFLAGS) -t c64 -C c64.cfg -u __EXEHDR__ -o kmon kmon.o
kmon.o: kmon.s
	$(AS) $(ASFLAGS) -t c64 -o kmon.o kmon.s

kmon.128: kmon.128.o
	$(CC) $(LDFLAGS) -t c128 -C c128.cfg -o kmon.128 kmon.128.o
kmon.128.o: kmon.s
	$(AS) $(ASFLAGS) -t c128 -o kmon.128.o kmon.s

kmon.16: kmon.16.o
	$(CC) $(LDFLAGS) -t c16 -C c16.cfg -o kmon.16 kmon.16.o
kmon.16.o: kmon.s
	$(AS) $(ASFLAGS) -t c16 -o kmon.16.o kmon.s

pip: pip.o
	$(CC) $(LDFLAGS) -t c64 -C c64.cfg -u __EXEHDR__ -o pip pip.o
pip.o: pip.s
	$(AS) $(ASFLAGS) -t c64 -o pip.o pip.s

pip.128: pip.128.o
	$(CC) $(LDFLAGS) -t c128 -C c128.cfg -o pip.128 pip.128.o
pip.128.o: pip.s
	$(AS) $(ASFLAGS) -t c128 -o pip.128.o pip.s

patch64: LDFLAGS += -t c64 -C c64.cfg -u __EXEHDR__ 
patch64: patch64.o

patch128: LDFLAGS += -t c128  
patch128: patch128.o

mtop: LDFLAGS += -t c64 -C c64.cfg -u __EXEHDR__
mtop: mtop.o

-include *.dep
