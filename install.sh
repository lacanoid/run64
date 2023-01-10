#!/bin/bash

DISKIMG=$1
shift

c1541 $DISKIMG -bwrite boot/bootsect.128 1 0 -bwrite boot/autostart64.128 1 1 
c1541 $DISKIMG -@ "b-a 8 1 0" -@ "b-a 8 1 1" -write tools/kmon
c1541 $DISKIMG -write c/config
c1541 $DISKIMG -write tools/pip 
c1541 $DISKIMG -write c/setup 
c1541 $DISKIMG -write c/uname
c1541 $DISKIMG -write c/smon
c1541 $DISKIMG -write tools/patch64
c1541 $DISKIMG -write vdc64/vdc64
#c1541 $DISKIMG -write tools/patch128
#c1541 $DISKIMG -write vdc64/vdc128
c1541 $DISKIMG -write tools/kmon64 -write tools/kmon128
c1541 $DISKIMG -write tools/pip64 -write tools/pip128
c1541 $DISKIMG -write tools/sjload !
#c1541 $DISKIMG -write fifth/5th
#c1541 $DISKIMG -write fifth/imenu
#c1541 $DISKIMG -write fifth/idump
c1541 $DISKIMG -write s/empty '================'
c1541 $DISKIMG -write s/startup,s
c1541 $DISKIMG -write s/issue,s
c1541 $DISKIMG -write s/ucl.dat
c1541 $DISKIMG -write s/keys

c1541 $DISKIMG -write s/empty '=-demos--------='

c1541 $DISKIMG -write c/colors
c1541 $DISKIMG -write c/banner
c1541 $DISKIMG -write c/hello.bas
c1541 $DISKIMG -write c/raster

for i in demos/*.prg
do
 c1541 $DISKIMG -write "$i" `basename "$i" .prg` # >/dev/null
done

while [ $# -gt 0 ]
do
    DIR=$1
    if [[ -d "$DIR" ]]
    then
        shift
        echo "Installing from directory" $DIR
        c1541 $DISKIMG -write s/empty '=-'`expr substr "$DIR""----------------" 1 14`
        for i in $DIR/*
        do
            c1541 $DISKIMG -write "$i" # >/dev/null
        done
    fi
done

c1541 $DISKIMG -write s/empty '=-user files---='

