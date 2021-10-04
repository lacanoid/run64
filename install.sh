#$/bin/bash

DISKIMG=$1
for i in prg/*
do
 echo $i
 c1541 $DISKIMG -write $i
done

c1541 $DISKIMG -bwrite bootsect.128 1 0 -bwrite bootsect2.128 1 1

