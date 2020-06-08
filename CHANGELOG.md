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
