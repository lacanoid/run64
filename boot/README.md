# Boot loader for Commodore 64 programs on Commodore 128

Unlike the C64, the Commodore 128 is able to boot automatically off a disk. This project contains a simple boot loader that loads a program in C128 mode, 
switches the machine into C64 mode and runs the loaded program, with no user intervention required. Now you can just drop .d64 files into your c128
emulator and they run automatically.

This project used [128boot64](https://github.com/rhalkyard/128boot64) as a starting point, 
but stuff got changed a lot since and more stuff added. 

This greatly speeds up loading of c64 programs on stock c128 because serial burst mode is used when loading. It currently runs only programs which are loaded and run like BASIC programs, 
that is LOAD + RUN. It works with many, but not all programs.

## Requirements

- [CC65](https://cc65.github.io).

- [VICE](http://vice-emu.sourceforge.net) (only needed for automated tests).

- A Commodore 128 or a Commodore 64.

- A floppy disk drive or disk-drive emulator (e.g.
  [SD2IEC](https://www.c64-wiki.com/wiki/SD2IEC)).

VICE's own functionality makes it somewhat pointless to use this on an
emulated system, but it does still work.

## Configuring

The `config.inc` file contains a few options to tailor the bootloader to a
particular application.

Programs that are normally launched with `LOAD "*",8` followed by `RUN`,
should work just fine with the defaults, however.

## Building

Just run `make` in this directory. If your CC65 and/or VICE executables are not
on your PATH, you will need to provide their installation locations in the
`CC65_HOME` and `VICE_HOME` variables (e.g. `make CC65_HOME=/opt/cc65
VICE_HOME=/opt/vice`).

`make check` constructs a bootable disk image (`test.d64`) with a small test
program (`hello`), and checks whether it boots correctly.

## Making disks bootable

To make an SD2IEC device bootable, copy `bootsect.128` to the root directory on
the SD card.

Boot loader uses sectors 0 and 1 on track 1. You can write it to the image with:

    $ c1541 my_disk_image.d81 -bwrite boot/bootsect.128 1 0 -bwrite boot/autostart64.128 1 1 

Ideally, the sectors should also be marked as allocated in the BAM (to prevent it
from being overwritten), AND, a file should be created to represent the boot
sector (so that the BAM allocation survives a `VALIDATE`), AND the file should be
placed at the end of the directory (or at least, not at the start), so that the
file listing isn't cluttered and `LOAD *` still works as expected.

By default the boot loader loads and runs file "*" which is the first file on the disk.
It can be useful tu use something like `kmon` here as a kind of shell.

    $ c1541 my_disk_image.d81 -@ "b-a 8 1 0" -@ "b-a 8 1 1" -write tools/kmon -write tools/kmon64 -write tools/kmon128

## Booting the machine

At startup, the C128 only looks for a boot sector on device 8, so for full
'hands off' operation, the bootloader must be installed on this device. 

On stock C64 you will have to use `LOAD"*",8` and `RUN` to start the program.
If you are using JiffyDOS, you can autostart just by pressing the `RUN` key.

## How it works

When the C128 boots, it looks for the string "cbm" at the start of Track 1,
Sector 0 (the first sector on the disk). If the string is present, it copies the
entire sector to $0B00, optionally loads further raw sectors (or a file), and
then jumps to the code immediately following the boot header.

The boot sector header, and the C128 boot code, are laid out in
[`bootsect.128.s`](bootsect.128.s). In summary, it loads the file in C128 mode at '$1C00',
moves it to '$0800' for C64 mode, then copies our C64 boot code embedded the boot sector into ram at `$8000`, 
makes a note of the device ID we booted off, and then kicks the machine over into C64 mode.

The C64 side of the autostarting (in [`autostart64.s`](autostart64.s)) is
handled by pretending to be a cartridge. Whether or not a cartridge is
physically present, the KERNAL checks for a cartridge autoboot signature at
`$8000`. Since RAM is not cleared on switching to C64 mode, our autostart code
remains intact, and gets jumped to during the boot process.

Since control is handed over to the "cartridge" fairly early on in the boot
process, we have to mirror portions of the KERNAL's `RESET` routine and the
BASIC cold-start code. Then we restore the program with OLD (oposite of NEW)
operation and finaly run it with NEWSTT.
