#$/bin/bash

DISKIMG=$1

c1541 $DISKIMG -bwrite boot/bootsect.128 1 0 -bwrite boot/autostart64.128 1 1 
c1541 $DISKIMG -@ "b-a 8 1 0" -@ "b-a 8 1 1" -write tools/kmon
c1541 $DISKIMG -write tools/pip
c1541 $DISKIMG -write tools/patch64
c1541 $DISKIMG -write vdc64/vdc64
c1541 $DISKIMG -write tools/patch128
c1541 $DISKIMG -write vdc64/vdc128
c1541 $DISKIMG -write c/smon
c1541 $DISKIMG -write fifth/5th
c1541 $DISKIMG -write tools/pip.128
c1541 $DISKIMG -write s/empty '================'
c1541 $DISKIMG -write s/startup,s
c1541 $DISKIMG -write s/issue,s
c1541 $DISKIMG -write s/empty '=--------------='

for i in c1541/*
do
 c1541 $DISKIMG -write "$i" # >/dev/null
done


