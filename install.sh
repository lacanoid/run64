#!/bin/bash

DISKIMG=$1

c1541 $DISKIMG -bwrite boot/bootsect.128 1 0 -bwrite boot/autostart64.128 1 1 
c1541 $DISKIMG -@ "b-a 8 1 0" -@ "b-a 8 1 1" -write tools/kmon -write tools/kmon.64 -write tools/kmon.128
c1541 $DISKIMG -write tools/pip -write tools/pip.64 -write tools/pip.128
c1541 $DISKIMG -write tools/patch64
c1541 $DISKIMG -write vdc64/vdc64
c1541 $DISKIMG -write tools/patch128
c1541 $DISKIMG -write vdc64/vdc128
c1541 $DISKIMG -write c/smon
c1541 $DISKIMG -write c/uname
c1541 $DISKIMG -write c/setup
#c1541 $DISKIMG -write fifth/5th
#c1541 $DISKIMG -write fifth/imenu
#c1541 $DISKIMG -write fifth/idump
#c1541 $DISKIMG -write tools/kmon.64
#c1541 $DISKIMG -write tools/kmon.128
#c1541 $DISKIMG -write tools/pip.64
#c1541 $DISKIMG -write tools/pip.128
c1541 $DISKIMG -write s/empty '================'
c1541 $DISKIMG -write s/startup,s
c1541 $DISKIMG -write s/issue,s

c1541 $DISKIMG -write s/empty '=-demos--------='

c1541 $DISKIMG -write c/colors
c1541 $DISKIMG -write c/hello.bas
c1541 $DISKIMG -write c/raster

for i in demos/*.prg
do
 c1541 $DISKIMG -write "$i" `basename "$i" .prg` # >/dev/null
done

c1541 $DISKIMG -write s/empty '=-extras-------='

for i in c1541/*
do
 c1541 $DISKIMG -write "$i" # >/dev/null
done

if [[ "$DISKIMG" =~ ".d64" ]] ; then exit; fi

for i in c1571/*
do
 c1541 "$DISKIMG" -write "$i" # >/dev/null
done

if [[ "$DISKIMG" =~ ".d71" ]] ; then exit; fi

for i in c1581/*
do
 c1541 "$DISKIMG" -write "$i" # >/dev/null
done


