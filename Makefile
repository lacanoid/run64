AS := ca65
CC := cl65
C1541 := c1541
X128 := x128

TIME := $(shell date +%y%m%d%H%M%S)
VOLNAME := run64 ${TIME},sy
PROGRAMS := 
VOLUMES := run64.d64 run64.d71 run64.d81

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

all: subdirs run64.d81

clean:
	rm -f $(PROGRAMS)
	rm -f $(VOLUMES)
	rm -rf *.o $(VOLUMES)

zap: clean
	rm -rf *.dep

test: subdirs run64.d81
#	$(X128) -debugcart -limitcycles 10000000 -sounddev dummy -silent -console -8 $+
	$(X128) run64.d81

disks: subdirs issue run64.d64 run64.d71 run64.d81

subdirs:
	cd boot ; make clean ; make
	cd tools ; make clean ; make
	cd vdc64 ; make clean ; make
#	cd fifth ; make $+

issue:
	echo "${VOLNAME}" > s/issue,s
	echo >> s/issue,s ; echo >> s/issue,s 
	fortune -s  > s/issue,s 
	echo >> s/issue,s ; echo >> s/issue,s 
	fortune -l >> s/issue,s 
#	echo >> s/issue,s ; echo >> s/issue,s 
#	fortune -o >> s/issue,s 

run64.d64: ${PROGRAMS} Makefile
	$(C1541) -format "${VOLNAME}" d64 run64.d64
	./install.sh run64.d64

run64.d71: ${PROGRAMS} Makefile
	$(C1541) -format "${VOLNAME}" d71 run64.d71
	./install.sh run64.d71

run64.d81: ${PROGRAMS} Makefile
	$(C1541) -format "${VOLNAME}" d81 run64.d81
	./install.sh run64.d81

-include *.dep
