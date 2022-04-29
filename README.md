# Run64 

A disk operating system for commodore 64/128. 

This project attempts to make a disk volume of useful system software for a c64/c128 system, 
to complement ROM based software normally used on these systems.
It is meant for be somewhat analogous to 'system disk' found on other systems.

It currently includes:
* A suite of [tools](tools) including shell/monitor program [kmon](docs/kmon.md)
* A [boot loader](boot) to set colors and autoboot programs in appropriate mode (c64 or c128)
* [driver/editor](vdc64) to use c128 VDC chip in c64 mode, providing 80 columns support
* a set of useful third party programs, such as drivers, languages, editors, etc

Makefile builds 1541, 1571 and 1581 disk images. 1581 + Jiffydos is recommended.

Rebuild with:

    $ make clean disks

Start with:

    $ x128 run64.d81

Or write the image to disk to run on actual hardware.
