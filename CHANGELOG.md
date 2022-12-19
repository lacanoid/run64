Version 0.9
===========
- `banner` program
- improved installer, blank image
- 'o' command - kmon.128 set key F8 to SAVE"filename",dev
- new 'k' command to inject characters into the keyboard buffer
- updated ramdos to one from c128 devpack
- dos commands @,$ to @$

Version 0.8
===========
- setup improvements, more settings
- bootctl boot parameters for choosing 40/80 columns and c64mode
- setup improvements, now saves settings
- added assembler.128
- added command . to kmon for sourcing text files
- bootloader128 more beautiful and hopefully faster
- command line args from c128 mode passed through autostart64
- added cpm+.d81 CP/M install disk
- added basic runners for kmon and pip to run the appropriate version
- cpm+.prg patched to boot from ram disk (M:)

Version 0.7
===========
- c128 versions of [kmon](docs/kmon.md) and [pip](docs/pip.md)
- new BRK handler in bootsect.128 for c128 mode which automatically starts c64 programs in c64 mode
- now you can just RUN "PROGRAM" in c128 mode and it will run in the appropriate mode.
- new vdc64 program to use VDC chip in C128 in C64 mode, providing support for 80 columns
- convert from and to trigrams in kmon (#)
- improved directory layout and build process
- pip interactive and ASCII/ANSI mode

Version 0.6
===========
- base conversions work now
- r : run command for loading and running programs
- b : boot command for rebooting and autostarting programs
- quoted arguments supported for r and b commands
- better color handling. color can now optionally be set from bootsect.128
- added new patch64 program which copies ROM to RAM and applies some patches
- added new pip program which will copy and print files

Version 0.5
===========
- major improvements

Version 0.4
===========
- raster demo :)

Version 0.3
===========
- set EAL and set VARTAB according to file loaded. 
  This seems to make more programs work, as some seem to use these to find the end of program. 
  It's a bit cleaner than calling obscure BASIC routines, too.

Version 0.2
===========
- check for stop key while booting in c128 to allow stopping of boot
- bootblock2 moved from $0400 to $0C00 to keep it more persistent
- now you can often use SYS3072 later to run a program in c64 mode
- less messy screen when booting
- added new "install" c128 basic program to write bootblock to disk (buggy)

Version 0.1
===========
- initial release
