# Run64 

A disk operating system for commodore 64/128. 

This project attempts to make a disk volume of useful system software for a c64/c128 system, 
to complement ROM based software normally used on these systems.
It is meant for be somewhat analogous to 'system disk' found on other systems.
It makes a commodore work more like say CP/M while retaining compatibility with most legacy software.

It currently includes:
* A [boot loader](boot) to set colors and autoboot programs in appropriate mode (c64 or c128)
* An interactive setup utility to configure the bootloader
* A suite of [tools](tools) including shell/monitor program [kmon](docs/kmon.md) and file utility [pip](doc/pip.md). 
These are separate for c64 and c128 mode, so you can take advantage of c128 features like faster disks.
* [driver/editor](vdc64) to use c128 VDC chip in c64 mode, providing 80 columns support
* a set of useful third party programs, such as drivers, languages, editors, etc. These come mostly from commodore sources.

Makefile builds 1541, 1571 and 1581 disk images. 1581 + Jiffydos is recommended.

Rebuild with:

    $ make clean disks

Start with:

    $ x128 run64.d81

Or write the image to disk to run on actual hardware.

## References
* Commodore sources from (https://github.com/mist64/cbmsrc)
* C128 version of assembler from (https://github.com/dmarlowe69/C128-Assembler-Development-System)
