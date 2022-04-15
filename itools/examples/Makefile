AS := ca65
CC := cl65
C1541 := c1541
X128 := x128
X64 := x64

TIME := $(shell date +%y%m%d%H%M%S)
PROGRAMS := idump imenu xy

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

ASFLAGS = -I .. --create-dep $(@:.o=.dep)

all: $(PROGRAMS)

clean:
	rm -f $(PROGRAMS)
	rm -rf *.o 

zap: clean
	rm -rf *.dep

check: $(PROGRAMS)
	$(X64) 5th # -debugcart -limitcycles 10000000 -sounddev dummy -silent -console -8 $+

imenu: build/imenu.o
	$(CC) $(LDFLAGS) -t c64 -C itools.cfg -u __EXEHDR__ -o imenu build/imenu.o
build/imenu.o: imenu.s
	$(AS) $(ASFLAGS) -t c64 -o build/imenu.o imenu.s

imenu-colors: build/imenu-colors.o
	$(CC) $(LDFLAGS) -t c64 -C itools.cfg -u __EXEHDR__ -o imenu-colors build/imenu-colors.o
build/imenu-colors.o: imenu-colors.s
	$(AS) $(ASFLAGS) -t c64 -o build/imenu-colors.o imenu-colors.s

xy: build/xy.o
	$(CC) $(LDFLAGS) -t c64 -C itools.cfg -u __EXEHDR__ -o xy build/xy.o
build/xy.o: xy.s
	$(AS) $(ASFLAGS) -t c64 -o build/xy.o xy.s


imenu.128: build/imenu.128.o
	$(CC) $(LDFLAGS) -t c128 -C itools.128.cfg  -u __EXEHDR__ -o imenu.128 build/imenu.128.o
build/imenu.128.o: imenu.s
	$(AS) $(ASFLAGS) -t c128 -o build/imenu.128.o imenu.s


idump: build/idump.o
	$(CC) $(LDFLAGS) -t c64 -C itools.cfg -u __EXEHDR__ -o idump build/idump.o
build/idump.o: idump.s
	$(AS) $(ASFLAGS) -t c64 -o build/idump.o idump.s

idump.128: build/idump.128.o
	$(CC) $(LDFLAGS) -t c128 -C itools.128.cfg -o idump.128 build/idump.128.o
build/idump.128.o: idump.s
	$(AS) $(ASFLAGS) -t c128 -o build/idump.128.o idump.s

-include *.dep
