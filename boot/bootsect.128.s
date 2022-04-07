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

.segment "DISKHDR"
magic:  .byte "CBM"     ; magic number for boot sector

addr:   .addr AS64      ; address to load chained blocks to
bank:   .byte $00       ; bank to load chained blocks to
nblks:  .byte $01       ; number of chained blocks to load

msg:    .asciiz NAME    ; name for "BOOTING ..." message

prg:    .asciiz ""      ; don't load a .PRG - we do that in stage2

        jmp boot128

; config parameters
bootctl:.byte 0       ; boot control
bootbgc:.byte 6       ; background color
bootfgc:.byte 1       ; foreground color
bootexc:.byte 6       ; border color

coladj = $ce5c  ; map of vic -> vdc colors
vdcout = $cdcc  ; vdcout routine

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

cmds128:                ; print commands to execute
        leaxy cmds
        jsr print
        jsr colors

kbdinj: LDX #$00        ; Inject stored keystrokes into keyboard buffer
@loop:  LDA keys, X
        BEQ boot128done
        STA KEYD, X
        INC NDX
        INX
        BNE @loop
boot128done:    ; return to BASIC
        rts

; print xy = null terminated string
print:
        stxy T1
        LDY #$00        ; Print load/run commands to screen
@loop:  LDA (T1),Y
        BEQ @done
        JSR CHROUT
        INY
        BNE @loop
@done:
        RTS

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
.segment "RUN64"

DQUOTE = $22
BLUE = $1F
LBLUE = $9A
CR = $0D
UP = $91
HOME = $13

cmds:
;        .byte 27,"T"   ; fix the screen top
;        .byte 14       ; lowercase
        .byte CR,CR
        .byte "DLOAD", DQUOTE
fnadr:
        .byte FILE
fnadr9:
        .byte DQUOTE
        .byte CR, CR, CR, CR, CR
;        .byte "SYS3072"
        .byte "RUN"
;       .byte HOME
        .byte UP,UP,UP,UP,UP,UP,UP
        .byte 0

keys:   .byte CR
        .byte CR
        .byte 0 ; keystrokes to inject into keyboard buffer

