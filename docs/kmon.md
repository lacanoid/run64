# kmon

Kmon is a command line interpreter (shell) for the commodore 64. It aims to runs with standard and compatible ROMs.
It is intented to provide similar functions as are available on other systems, such as configuring and running programs.
It is especially focused on running transient programs, that is programs which return control to the system when they are finished.

It has been influenced by systems like kmon on RT-11, shell on unix, ccp on CP/M, Amiga CLI and command.com on MS-DOS.
It aims to be useful while remaining small.

It is somewhat of a combination of machine language monitor and a shell for running programs.
If fact, it has started as a fork of supermon64 code

## Commands

### Directory

```
d
```

List directory of current disk device.

```
d 9
```

List directory of disk device 9.

```
d a
```

List directory of disk device 10.


### Exit to BASIC

```
x
```

Return to BASIC READY mode. When you wish to return to kmon,
command "SYS 8".  

### Running programs

#### Run

```
r "color test"
```

Load run the program named "color test" from current disk device.

```
r
```
Run already loaded program.

#### Boot

```
b 
```

Reboot the system, autostarting program ":*" (which is usually kmon)

```
b "smon"
```
     
Reboot the system, autostarting program "smon". 
This can be useful for running programs which won't run right with `r` command.


### File Handling

#### Load 

```
l
```
Load any program from cassette #1.

```
l "ram test"
```

Load from cassette #1 the program named "ram test".

```
l "ram test",08
```

Load from disk (device 8) the program named  "ram test". This
command leaves basic pointers unchanged.

#### Save

```
s "program name",01,0800,0c80
```

Save to cassette #1 memory from 0800 hex up to but not including
0c80 hex and name it "program name".

```
s "0:program name",08,1200,1f50
```
     
Save to disk drive #0 memory from 1200 hex up to but not including
1f50 hex and name it "program name".

##
