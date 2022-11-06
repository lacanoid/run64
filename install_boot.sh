#!/bin/bash

DISKIMG=$1

c1541 $DISKIMG -bwrite boot/bootsect.128 1 0 -bwrite boot/autostart64.128 1 1 
c1541 $DISKIMG -@ "b-a 8 1 0" -@ "b-a 8 1 1" -write tools/kmon
c1541 $DISKIMG -write c/setup -write c/config
c1541 $DISKIMG -write tools/kmon.64 -write tools/kmon.128
c1541 $DISKIMG -write s/empty '================'