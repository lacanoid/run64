
VDC64
=====

This is a port of commodore 128 screen editor to commodore 64. 
It is intended to be used in c64 mode on a commodore 128.
[VDC chip which provides 80 column support](https://en.wikipedia.org/wiki/MOS_Technology_8563) 
is quite accesible in c64 mode
so basically the same code should run, with some adaptations.

Why do this? So you can run c64 programs in 80 columns!
It works great with programs which use BASIC/KERNAL to print to screen.

It provides 80 column support as well as additional features, 
such as c128 escape sequences and windowing.

c128 keyboard scanning and programmable function keys are currently
disabled so the whole thing can fit in the $c000-$cfff area.
If you enable them you will have to assemble to a different address, say $8000.

Code is from [EDITOR 128](https://github.com/mist64/cbmsrc/tree/master/EDITOR_C128),
adapted with the following modifications:
- adapted to [ca65 assembler](https://cc65.github.io/)
- resides at $c000-$cfff just like c128 editor. 
  [Jump table at $c000](https://github.com/franckverrot/EmulationResources/blob/master/consoles/commodore/C128%20RAM%20Map.txt#L1551) is the same, too.
- declare.src replaced with defs64.inc
- variables PNT,USER,LSXP,LSTP,INDX,TBLX,PNTR,COLOR,RVS,QTSW,INSRT now in their corresponding c64 locations
- updated swapper to support this
- editor.src replaced with vdc64.s, where most of the customization is
- wrapper to run this as a normal c64 program, check for vdc
- functions for 128 like memory management for 64 mode (getcfg, indfet, fetch)
- 40/80 key is not readable in c64 mode, so initialize to 80 column mode with current vic colors
- switched vdc colors 11 and 12, this seems to match vic colors better. 
- frees up 14 zero page locations $e4-$f2 as they are not used by the new editor
- conditional assembly for keyboard scan and function key routines
- locations of new editor variables are mostly different, on c128 they are around $0a00, here they are after jump table at $c000.

Using
-----
Load and run "vdc64" program on c128 in c64 mode. It will install itself in the $C000-$CFFF area.

- STOP+RESTORE will deactivate the editor and return to 40 column mode
- you can reactivate the 80 column mode and the new editor with SYS 49152
- switch between 40/80 mode with command PRINT CHR$(27);"X"
- switch between 40/80 mode with CTRL-[ x

