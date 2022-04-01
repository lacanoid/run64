# Run64 tools

This directory contains a number of tools written specifically for run64.

They include:

        * [kmon](../docs/kmon.md) - command line interpreter
        * pip - peripheral interchange program        
        * patch64 - copy ROMs to RAM and apply patches, so it will run
        * patch128 - run c64 OS in c128 mode (broken)

## Changelog

### 2022-04-01: pip 0.4 et al
        * build c128 binary pip.128
        * kmon no longer installs BRK handler by default
        * bootsect.128 init $800 area for BRK

