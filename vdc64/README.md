To do
=====
- *DONE* move 4 vars to zp
- *DONE* better bell
- *DONE* interrupt handler
- *DONE* keep initial cursor color & position in 40 column mode
- *DONE* reverse + clr hack
- *DONE* splitscreen and 'modes'
- fix SCREEN/SCRORG to return proper screen size
- fix PLOT to work
- function keys
- scnkey for extra keys
- SYS call to activate/swap
- case switching (done twice now?)
- cursor bugs in 40 column mode if no feature_irq (cursor doesn't always dissapear)
- extra returns in basic prompt
- harmonize new editor variables better with their c128 counterparts
- make this work nicely with boot
- reverse should use vdc reverse attribute
- some tests (super expander, PLOT & SCREEN/SCRORG)
- make 80 column stuff optional

About
=====

This is a port of commodore 128 screen editor to commodore 64. 
It is intended to be used in c64 mode on a commodore 128.
VDC chip which provides 80 column support is quite accesible in c64 mode
so basically the same code should run, with some adaptations.

Why do this? So you can run c64 programs in 80 columns!

It provides 80 column support as well as additional features, 
such as c128 escape sequences and windowing.

c128 keyboard scanning and programmable function keys are currently
disabled so the whole thing can fit in the $c000-$cfff area.
If you enable them you will have to assemble to a different address, say $8000.

Code is from [EDITOR 128](https://github.com/mist64/cbmsrc/tree/master/EDITOR_C128),
adapted with the following modifications:
- adapted to [ca65 assembler](https://cc65.github.io/)
- resides at $c000-$cfff just like c128 editor. jump table at $c000 is the same, too.
- declare.src replaced with defs64.inc
- variables PNT,USER,LSXP,LSTP,INDX,TBLX,PNTR,COLOR,RVS,QTSW,INSRT now in their corresponding c64 locations
- updated swapper to support this
- editor.src replaced with vdc64.s
- wrapper to run this as a normal c64 program, check for vdc
- functions for 128 like memory management for 64 mode (getcfg, indfet, fetch)
- 40/80 key is not readable in c64 mode
- initialize to 80 column mode with current vic colors
- switched colors 11 and 12 on vdc, this seems to match vic colors better. 
- freed up zero page locations $dd-$f2 as they are not used by the new editor
- conditional assembly for keyboard scan and function key routines
- locations of new c128 variables are mostly different
- STOP+RESTORE will deactivate the editor and return to 40 column mode
- you can reactivate the 80 column mode and the new editor with SYS 49152
- switch between 40/80 mode with command PRINT CHR$(27);"X"
- switch between 40/80 mode with CTRL-[ x

