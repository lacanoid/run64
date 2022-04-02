AS := ca65
CC := cl65
C1541 := c1541
X128 := x128

TIME := $(shell date +%y%m%d%H%M%S)
VOLNAME := run64 ${TIME},sy
PROGRAMS := bootsect.128 autostart64.128
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

bootsect.128: LDFLAGS += -C autostart.cfg --verbose --debug --debug-info
bootsect.128: bootsect.128.o autostart64.128.o autostart64.o

autostart64.128: LDFLAGS += -C autostart.cfg
autostart64.128: bootsect.128.o autostart64.128.o autostart64.o

-include *.dep
