#$/bin/bash

DISKIMG=$1

c1541 $DISKIMG -bwrite bootsect.128 1 0 -bwrite autostart64.128 1 1

for i in prg/*
do
 c1541 $DISKIMG -write "$i" >/dev/null
done


