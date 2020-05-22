; C128 boot sector that copies C64 autostart code to $8000, and then switches 
; to C64 mode.

.include "config.inc"
.include "defs.inc"

.import __AUTOSTART64_SIZE__, __AUTOSTART64_LOAD__, __AUTOSTART64_RUN__
.import __GO64_SIZE__, __GO64_LOAD__, __GO64_RUN__
.import devnum_sav

KBDBUF = $034A  ; start of keyboard buffer for C64 screen editor
KBDCNT = $D0    ; keyboard buffer count for C64 screen editor
DEVNUM = $BA

.segment "DISKHDR"
magic:  .byte "CBM"     ; magic number for boot sector

addr:   .addr $0400     ; address to load chained blocks to
bank:   .byte $00       ; bank to load chained blocks to
nblks:  .byte $01       ; number of chained blocks to load

msg:    .asciiz NAME    ; name for "BOOTING ..." message

prg:    .asciiz ""      ; don't load a .PRG - we do that in stage2

.segment "BOOT128"
print:  LDX #$00        ; Print load/run commands to screen
@loop:  LDA cmds, X
        BEQ @done
        JSR CHROUT
        INX
        BNE @loop
@done:

kbdinj: LDX #$00        ; Inject stored keystrokes into keyboard buffer
@loop:  LDA keys, X
        BEQ @done
        STA KBDBUF, X
        INC KBDCNT
        INX
        BNE @loop
@done:
        rts

; go to 64 mode, preserving 
.segment "RUN64"
run64:
; set some 
        lda #12
        sta $d020
        sta 241

        ldx #(40*4)
@loop:  sta COLOR +40*15 - 1, X
        sta COLOR +40*19 - 1, X
        DEX
        bne @loop

; copy c64 autostart to screen memory
        LDX  #< (__AUTOSTART64_SIZE__ + 1)
@loop2: LDA __AUTOSTART64_LOAD__ - 1, X
        STA VICAS64 - 1, X
        DEX
        BNE @loop2
        rts

; copy go64 routine to boot block screen memory, so that boot block buffer can be freed
        LDX  #< (__GO64_SIZE__ + 1)
@loop3: LDA __GO64_LOAD__ - 1, X
        STA __GO64_RUN__ - 1, X
        DEX
        BNE @loop3
        rts


DQUOTE = $22
BLUE = $1F
LBLUE = $9A
CR = $0D
UP = $91
HOME = $13

cmds:
        .byte 27,"T",CR,CR
        .byte "LOAD", DQUOTE, FILE, DQUOTE, ",8"
.if LOADMODE
        .byte ",", .string(LOADMODE)
.endif
        .byte CR, CR, CR, CR, CR
        .byte "SYS1024"
;        .byte "IFNOTDSTHENSYS1024"
;        .byte "SYS3072"
        .byte HOME
        .byte 0

keys:   .byte CR
        .byte CR
;        .byte "SYS 3072:", CR
;        .byte "SYS 1024:", CR
        .byte 0 ; keystrokes to inject into keyboard buffer

