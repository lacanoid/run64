; C128 boot sector that copies C64 autostart code to $8000, and then switches 
; to C64 mode.

.include "config.inc"
.include "defs128.inc"
.include "macros.inc"
.INCLUDE "boot.inc"

.import __AUTOSTART64_SIZE__, __AUTOSTART64_LOAD__, __AUTOSTART64_RUN__
.import __VICGO64_SIZE__, __VICGO64_LOAD__, __VICGO64_RUN__
.import __CARTHDR_SIZE__, __CARTHDR_LOAD__

C64DEST = $0801
AS64    = $0C00

coladj = $ce5c  ; map of vic -> vdc colors
vdcout = $cdcc  ; vdcout routine

LOWERCASE = 14
DQUOTE = $22
CR = $0D
UP = $91
HOME = $13

.segment "DISKHDR"
magic:  .byte "CBM"     ; magic number for boot sector

addr:   .addr AS64      ; address to load chained blocks to
bank:   .byte $00       ; bank to load chained blocks to
nblks:  .byte $01       ; number of chained blocks to load

msg:    .asciiz NAME    ; name for "BOOTING ..." message

prg:    .asciiz ""      ; don't load a .PRG - we do that in stage2

        jmp boot128

; config parameters (offest 17)
bootctl:.byte $00      ; boot control $80 = 80columns , $40 = run in c64 mode
bootbgc:.byte 6       ; background color
bootfgc:.byte 1       ; foreground color
bootexc:.byte 6       ; border color

; actual bootloader
.segment "BOOT128"
boot128:
; clear $800 area so that running a C64 program will trigger a BRK
        ldx #0
        txa
@b1:    sta $800,X
        dex
        bne @b1        

; set BRK vector
        lda #<AS64
        sta IBRK
        lda #>AS64
        sta IBRK+1

; check for abort
        jsr STOP            ; check for stop
        beq boot128done

;        lda SHFLAG          ; check for shift
;        bne boot128done

; set 40/80 column mode
        bit MODE
        bmi @sw0      ; started in 80
        bit bootctl
        bpl @sw0
        ; switch to 80 column mode
        jsr SWAPPER
@sw0:           

; set colors
        ldx bootfgc
        bmi cfg1
        bit MODE
        bpl @l1
        lda coladj,X
        tax
@l1:    stx COLOR
cfg1:   ldx bootbgc
        bmi cfg2        
        stx BGCOL0
        cpx #11
        bne @l2
        inx
@l2:    lda coladj,X
        ldx #$1a      ; color register
        jsr vdcout
cfg2:   lda bootexc
        bmi cfg3
        sta EXTCOL
cfg3:
        ; copy settings
        ldx #4
@loop21:lda bootctl-1,X
        sta __CARTHDR_LOAD__ + 9 - 1,X
        dex
        bne @loop21

        jsr colors    ; set text foreground color

NEW_LOADER=1

; load a program
        LDA #$80            ; disable kernel control messages
        JSR SETMSG          ; and enable error messages

        JSR PRIMM
        .byte LOWERCASE,UP,0

        leaxy fnadr
        lda #fnadr9-fnadr
        jsr SETNAM

        lda #1
        ldx FA
        bne TBINIT1
        ldx #8
TBINIT1:ldy #0
        jsr SETLFS

        lda #0        ; load, not verify
        ldxy TXTTAB
        JSR LOAD

        lda bootctl
        and #$40
        beq @r1
        jmp AS64            ; start a program in c64 mode
@r1:    JMP JRUN_A_PROGRAM  ; start a program

boot128done:    ; return to BASIC
        rts

; set some colors
colors:
;        lda #14
;        sta EXTCOL
;        sta COLOR

        ldx #(40*5)
@loop:
        lda BGCOL0
        sta COLORAM +40*15 - 1, X
        sta COLORAM +40*20 - 1, X
        lda COLOR
        sta COLORAM, X
        sta COLORAM +40*5  - 1, X
        DEX
        bne @loop
        rts

; go to 64 mode, preserving program through c65 reset routine and running it
; this is called from $0C00, which is the user entry point
;.segment "RUN64"

fnadr:
        .byte FILE
fnadr9:
