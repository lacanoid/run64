

BOOT:
* autoboot on c64 is broken (shell should run configured program)

KMON:
* `o` - old command, load and edit. perhaps `e` or `l`
* use programmable function keys for:
** return to monitor
** save current program
* make `r!` work by running sjdos
* get command line args
* batch files get stuck (64 mode only)
* boot command must recognize drive
* boot command c128 mode choose program (now always runs :*)
* boot command switch drive numbers
* boot command boot disk images

PIP:
* hex mode (/x)
* info mode (/i) - show only load address and length

FASTLOADER:
* ! should auto load and run program passed as arg or ":*"
* patch64 

CP/M
* boot customizer
* ram disk installer

UNAME:
x=peek(65534)
c128:  23
c64:   72
vic20: 114
superpet:   66
pet 2001:   107
pet 3008:   27
c510:   229
cbm2:   214
ted:    peek reads from ram
