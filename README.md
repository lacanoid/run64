# Boot loader for Commodore 64 programs on Commodore 128

Unlike the C64, the Commodore 128 is able to boot automatically off a disk. This
project contains a simple boot loader that switches the machine into C64 mode,
and automatically loads and runs a program, with no user intervention required.

## Requirements

- [CC65](https://cc65.github.io).

- [VICE](http://vice-emu.sourceforge.net) (only needed for automated tests).

- A Commodore 128 (sorry, C64 owners).

- A floppy disk drive or disk-drive emulator (e.g.
  [SD2IEC](https://www.c64-wiki.com/wiki/SD2IEC)).

VICE's own autostart functionality makes it rather pointless to use this on an
emulated system, but it does still work.

## Configuring

The `config.inc` file contains a few options to tailor the bootloader to a
particular application.

Programs that are normally launched with `LOAD "*",8,1` followed by `RUN`,
shoudl work just fine with the defaults, however.

## Building

Just run `make` in this directory. If your CC65 and/or VICE executables are not
on your PATH, you will need to provide their installation locations in the
`CC65_HOME` and `VICE_HOME` variables (e.g. `make CC65_HOME=/opt/cc65
VICE_HOME=/opt/vice`).

`make check` constructs a bootable disk image (`test.d64`) with a small test
program (`testboot`), and checks whether it boots correctly.

## Making disks bootable

To make an SD2IEC device bootable, copy `bootsect.128` to the root directory on
the SD card.

Making a bootable disk image is a little bit more involved. The boot loader must
be located at Track 1, Sector 0. A quick and dirty way to do it (as used in the
`test.d64` image in the Makefile) is just to write the raw contents of
`bootsect.128` to the sector. However, bypassing DOS in this way means that if
any data is stored in that sector alrady, it will be overwritten, and writing
further data to the disk is liable to overwrite the boot sector.

Ideally, the sector should also be marked as allocated in the BAM (to prevent it
from being overwritten), AND, a file should be created to represent the boot
sector (so that the BAM allocation survives a `VALIDATE`), AND the file should be
placed at the end of the directory (or at least, not at the start), so that the
file listing isn't cluttered and `LOAD *` still works as expected.

As far as I am aware, there isn't any cross-platform tool that can do all these
things. I've got some plans for a general-purpose Python library for working
with CBM disks, so watch this space.

## Booting the machine

At startup, the C128 only looks for a boot sector on device 8, so for full
'hands off' operation, the bootloader must be installed on this device. However,
the `BOOT` command in C128 BASIC can be used to boot from any device (e.g. `BOOT
U10` to boot from device 10). While this is supported by the bootloader (it will
automatically continue loading from the same device after switching to C64
mode), some C64 software is hardcoded to load from device 8 and will not work if
booting off another device.

## How it works

When the C128 boots, it looks for the string "cbm" at the start of Track 1,
Sector 0 (the first sector on the disk). If the string is present, it copies the
entire sector to $0B00, optionally loads further raw sectors (or a file), and
then jumps to the code immediately following the boot header.

The boot sector header, and the C128 boot code, are laid out in
[`bootsect.128.s`](bootsect.128.s). In summary, it copies our C64 boot code
embedded the boot sector into ram at `$8000`, makes a note of the device ID we
booted off, and then kicks the machine over into C64 mode.

The C64 side of the autostarting (in [`autostart64.s`](autostart64.s)) is
handled by pretending to be a cartridge. Whether or not a cartridge is
physically present, the KERNAL checks for a cartridge autoboot signature at
`$8000`. Since RAM is not cleared on switching to C64 mode, our autostart code
remains intact, and gets jumped to during the boot process.

Since control is handed over to the "cartridge" fairly early on in the boot
process, we have to mirror portions of the KERNAL's `RESET` routine and the
BASIC cold-start code. Once everything is ready for action, we print the
appropriate `LOAD` and `RUN` incantations to the screen, position the cursor so
that it will be on the `LOAD` line when BASIC starts, and then inject two
carriage-returns into the keyboard buffer.

When we hand control back to BASIC, it starts consuming the keyboard buffer,
which causes the commands cued up on the screen to be executed, and voilà! We
have autostart!

For a cleaner look, the `LOAD` and `RUN` commands are printed to the screen with
the same colour as the background, but setting `HIDECMDS` to 0 in `config.inc`
disables this behavior.

## Tested platforms

So far, I've only tested this on my own machine (128DCR, with internal 1571,
'big box' 1541 and SD2IEC). However, it should work on any 128, and with any
drive that supports direct sector access (or at least emulates it for the boot
sector, like the SD2IEC does).

## TODO

- Tool to automatically (and correctly) install boot loader to existing
  disks/disk-images.

- When booting from SD2IEC, add option to mount a disk image or change
  directories.

- Load program *before* going into 64 mode (MUCH faster on drives that support
  fast serial, but will need to handle differences in memory layout).

- Allow device number to be overridden, to support booting from one device and
  loading from another.
