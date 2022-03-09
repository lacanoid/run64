Version 0.7
===========

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
