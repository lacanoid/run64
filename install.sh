#$/bin/bash

DISKIMG=$1

c1541 $DISKIMG -@ "b-a 8 1 0" -@ "b-a 8 1 1" -bwrite bootsect.128 1 0 -bwrite autostart64.128 1 1 
c1541 $DISKIMG -write patch64
c1541 $DISKIMG -write patch128

for i in prg/*
do
 c1541 $DISKIMG -write "$i" >/dev/null
done


