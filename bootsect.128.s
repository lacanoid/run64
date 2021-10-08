; C128 boot sector that copies C64 autostart code to $8000, and then switches 
; to C64 mode.

.include "config.inc"
.include "defs128.inc"

.import __AUTOSTART64_SIZE__, __AUTOSTART64_LOAD__, __AUTOSTART64_RUN__
.import __VICGO64_SIZE__, __VICGO64_LOAD__, __VICGO64_RUN__
.import __CARTHDR_SIZE__, __CARTHDR_LOAD__

C64DEST = $0801

.segment "DISKHDR"
magic:  .byte "CBM"     ; magic number for boot sector

addr:   .addr $0C00     ; address to load chained blocks to
bank:   .byte $00       ; bank to load chained blocks to
nblks:  .byte $01       ; number of chained blocks to load

msg:    .asciiz NAME    ; name for "BOOTING ..." message

prg:    .asciiz ""      ; don't load a .PRG - we do that in stage2

        jmp boot128

; config parameters
bootctl:.byte 0         ; boot control
bootbgc:.byte 255       ; background color
bootfgc:.byte 255       ; foreground color
bootexc:.byte 255       ; border color

; actual bootloader
.segment "BOOT128"
boot128:  
        lda bootfgc
        bmi cfg1
        sta COLOR
cfg1:   lda bootbgc
        bmi cfg2
        sta BGCOL0
cfg2:   lda bootexc
        bmi cfg3
        sta EXTCOL
cfg3:

cmds128:
        LDX #$00        ; Print load/run commands to screen
@loop:  LDA cmds, X
        BEQ @done
        JSR CHROUT
        INX
        BNE @loop
@done:

kbdinj: LDX #$00        ; Inject stored keystrokes into keyboard buffer
@loop:  LDA keys, X
        BEQ @done
        STA KEYD, X
        INC NDX
        INX
        BNE @loop
@done:
        rts

; go to 64 mode, preserving program through c65 reset routine and running it
; this is called from $0C00, which is the user entry point
.segment "RUN64"
run64:
        jsr STOP
        bne colors
        rts             ; stop was presseed, do nothing

; set some colors
colors:
        lda #12
        sta EXTCOL
        sta COLOR

        lda BGCOL0
        ldx #(40*5)
@loop:  sta COLORAM +40*15 - 1, X
        sta COLORAM +40*20 - 1, X
        DEX
        bne @loop

; copy c64 autostart to screen memory
        LDX  #< (__AUTOSTART64_SIZE__ + 1)
@loop2: LDA __AUTOSTART64_LOAD__ - 1, X
        STA VICAS64 - 1, X
        DEX
        BNE @loop2

        LDX #< (__CARTHDR_SIZE__)
@loop3: LDA __CARTHDR_LOAD__ - 1, X
        STA VICCRTB - 1, X
        DEX
        BNE @loop3

; copy go64 routine to boot block screen memory, so that boot block buffer can be freed
        LDX  #< (__VICGO64_SIZE__ + 1)
@loop4: LDA __VICGO64_LOAD__ - 1, X
        STA VICGO64 - 1, X
        DEX
        BNE @loop4

; adjust end-of load pointer for 64
        clc
        lda EAL
        sbc SAL
        sta EAL
        lda EAL+1
        sbc SAL+1
        sta EAL+1
        clc
        lda EAL
        adc #< C64DEST
        sta EAL
        lda EAL+1
        adc #> C64DEST
        sta EAL+1
;        tax

        jmp VICGO64 + 3


DQUOTE = $22
BLUE = $1F
LBLUE = $9A
CR = $0D
UP = $91
HOME = $13

cmds:
        .byte 27,"T"   ; fix the screen top
        .byte CR,CR
        .byte "DLOAD", DQUOTE, FILE, DQUOTE
;        .byte "LOAD", DQUOTE, FILE, DQUOTE, ",8"
.if LOADMODE
;        .byte ",", .string(LOADMODE)
.endif
        .byte CR, CR, CR, CR, CR
;        .byte "SYS1024"
;        .byte "IFNOTDSTHENSYS1024"
        .byte "SYS3072"
        .byte HOME
        .byte 0

keys:   .byte CR
        .byte CR
;        .byte "SYS 3072:", CR
;        .byte "SYS 1024:", CR
        .byte 0 ; keystrokes to inject into keyboard buffer

