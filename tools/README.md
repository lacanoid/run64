# Run64 tools

This directory contains a number of tools written specifically for run64.

They include:

1. [kmon](../docs/kmon.md) - command line interpreter
1. [pip](../docs/pip.md) - file maintainance utility        
1. patch64 - copy ROMs to RAM and apply patches, so it will run
1. patch128 - run c64 OS in c128 mode (broken)

# To do

## kmon
1. kmon run batch files
1. kmon startup batch file 
1. kmon aliases
1. kmon n(ew) command
1. kmon o(ld) command
1. kmon m(emory) command
1. kmon c(hdir) command
1. kmon editor contexts

## pip
1. pip CLI options &check;
1. pip file copying
1. pip ASCII/ANSI mode &check;
1. pip file load address + size
1. pip hex mode
1. pip pause mode
1. pip as engine for help (show only part of file)

## Changelog

### 2022-04-02: pip 0.4 et al
        * pip has interactive mode
        * pip can convert from ASCII/ANSI (use /a option)

### 2022-04-01: pip 0.4 et al
        * build c128 binary pip.128
        * kmon no longer installs BRK handler by default
        * bootsect.128 init $800 area for BRK
        * kmon j(ump) and g(o) commands work better
        * kmon memory command > works

