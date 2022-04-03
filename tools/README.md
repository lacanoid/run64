# Run64 tools

This directory contains a number of tools written specifically for run64.

They include:

1. [kmon](../docs/kmon.md) - command line interpreter
1. pip - peripheral interchange program        
1. patch64 - copy ROMs to RAM and apply patches, so it will run
1. patch128 - run c64 OS in c128 mode (broken)

# To do
1. kmon run batch files
1. kmon startup batch file 
1. kmon n(ew) command
1. kmon o(ld) command
1. kmon m(emory) command
1. pip CLI options
1. pip file copying
1. pip ASCII/ANSI mode
1. pip hex mode

## Changelog

### 2022-04-01: pip 0.4 et al
        * build c128 binary pip.128
        * kmon no longer installs BRK handler by default
        * bootsect.128 init $800 area for BRK
        * kmon j(ump) and g(o) commands work better
        * kmon memory command > works
        * pip has interactive mode

