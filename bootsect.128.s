; C128 boot sector that copies C64 autostart code to $8000, and then switches 
; to C64 mode.

.include "config.inc"
.include "defs128.inc"
.include "macros.inc"

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
bootctl:.byte 0       ; boot control
bootbgc:.byte 2       ; background color
bootfgc:.byte 1       ; foreground color
bootexc:.byte 10      ; border color

; actual bootloader
.segment "BOOT128"
boot128:
        jsr STOP            ; check for stop
        beq boot128done
;        lda SHFLAG          ; check for shift
;        bne boot128done

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
boot128done:
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
run64:
        jsr STOP
        bne run65
        rts             ; stop was presseed, do nothing
run65:
        leaxy banner
        jsr print

; Screen memory at $400 survives transition to c64 mode. 
; Below $400 is wiped on reset. Above $800 (up to $D000) is the loaded program.
; copy c64 autostart to screen memory
        LDX  #< (__AUTOSTART64_SIZE__ + 1)
@loop2: LDA __AUTOSTART64_LOAD__ - 1, X
        STA VICAS64 - 1, X
        DEX
        BNE @loop2

; copy settings
        ldx #4
@loop21:lda bootctl-1,X
        sta __CARTHDR_LOAD__ + 9 - 1,X
        dex
        bne @loop21

; copy cartridge autostart
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

; adjust EAL (end-of load pointer) for 64 mode
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

banner:
        .byte 14,145,"GO 64  ",0

cmds:
        .byte 27,"T"   ; fix the screen top
;        .byte 14       ; lowercase
        .byte CR,CR
        .byte "DLOAD", DQUOTE, FILE, DQUOTE
        .byte CR, CR, CR, CR, CR
;        .byte 151     ; hide
        .byte "SYS3072"
;        .byte 153     ; show
        .byte HOME
        .byte 0

keys:   .byte CR
        .byte CR
        .byte 0 ; keystrokes to inject into keyboard buffer

