; C64 program autostarter
; Copyright 2018, Richard Halkyard <rhalkyard@gmail.com>
; Copyright 2020, Ziga Kranjec <lacanoid@ljudmila.org>

.include "config.inc"
.include "defs.inc"

.import __AUTOSTART64_SIZE__, __AUTOSTART64_LOAD__, __AUTOSTART64_RUN__
.import __CARTHDR_LOAD__, __CARTHDR_RUN__, __CARTHDR_SIZE__

.export devnum_sav

KBDBUF = $0277  ; start of keyboard buffer for C64 screen editor
KBDCNT = $C6    ; keyboard buffer count for C64 screen editor
DEVNUM = $BA    ; zeropage variable for last-used device #

.segment "CARTHDR"
        ; cartridge header
        .addr hardrst   ; hard reset vector
        .addr $fe5e     ; soft reset vector: return to NMI handler immediately after cartridge check
        .byte $C3, $C2, $CD, $38, $30   ; 'CBM80' magic number for autostart cartridge

CINT   = $FF5B  ; Initialize Screen Editor and VIC-II Chip
RESTOR = $FD15  ; Restore RAM Vectors for Default I/O Routines
RAMTAS = $FD50  ; Perform RAM Test and Set Pointers to the Top and Bottom of RAM
IOINIT = $FDA3  ; Initialize CIA I/O Devices

hardrst: STX $D016       ; modified version of RESET routine (normally at $FCEF-$FCFE)
        JSR IOINIT
        JSR RAMTAS
        JSR RESTOR

        jsr restoreas64
        jmp init2

; restore segmern AUTOSTART64 from VICAS64 to TBUFFER
restoreas64:
copy:   
        txa
        tay
        LDX  #< (__AUTOSTART64_SIZE__ + 1)
@loop:  LDA VICAS64 -1, X 
        STA __AUTOSTART64_RUN__ - 1, X
        DEX
        BNE @loop
        tya 
        tax
        rts
;bootscr_data:

.segment "AUTOSTART64"
        jmp old
        jmp old2

; continue initializaton 
init2:
        jsr restorecrtb
        JSR CINT
        CLI

        JSR $E453       ; modified version of BASIC cold-start (normally at $E394-$E39F)
        JSR $E3BF
        JSR $E422
        LDX #$FB
        TXS
        ; normally the main BASIC loop starts here, but we have more work to do ;)

;        LDA devnum_sav  ; restore saved device #
;        STA DEVNUM

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

        LDA #<bootmsg
        LDY #>bootmsg
        JMP $A478       ; jump into BASIC

LINKPRG = $A533

; restore basic program after reset, un-new
; these two must be called from basic as SYS820:SYS823:CLR or such
old:    lda #1
        sta 2050
        jsr LINKPRG
        rts
old2:   clc
        lda 781
        adc #2
        sta 45
        sta 2
        lda 35
        adc #0
        sta 46
        rts

; restore data overwritten by cartridge autostart header from VICCRTB
restorecrtb:   
        LDX  #< (__CARTHDR_SIZE__ + 1)
@loop:  LDA VICCRTB - 1, X
        STA __CARTHDR_RUN__ - 1, X
        DEX
        BNE @loop
        rts




DQUOTE = $22
BLUE = $1F
LBLUE = $9A
CR = $0D
UP = $91
HOME = $13

bootmsg:.byte NAME, 0

cmds:
.if HIDECMDS
        .byte BLUE      ; make command text 'invisible' against default blue background
.endif
.repeat 2
        .byte CR        ; leave space for READY prompt, since this actually gets printed first
.endrepeat
        .byte "SYS820:SYS823:"
;        .byte "D=PEEK(", .sprintf("%d", DEVNUM), "):"
;        .byte "LOAD", DQUOTE, FILE, DQUOTE, ",D,", .string(LOADMODE)
;        .byte "POKE2050,1:SYS42291:"
;        .byte "POKE46,PEEK(35)-(PEEK(781)>253):"
;        .byte "POKE45,PEEK(781)+2AND255:"
;        .byte "POKE2,0:"
        .byte "CLR"
.repeat 3;
        .byte CR        ; leave space for SEARCHING/LOADING/READY message sequence
.endrepeat
        .byte "RUN:", CR ; last line must be CR-terminated before printing READY prompt
;        .byte "LIST:", CR ; last line must be CR-terminated before printing READY prompt

        .byte HOME
.repeat 5
        .byte CR        ; move cursor back up to starting point
.endrepeat

.if HIDECMDS
        .byte LBLUE     ; reset text colour so that status messages are visible
.endif
        .byte 0

keys:   .byte CR, CR, CR, 0 ; keystrokes to inject into keyboard buffer

devnum_sav:     .byte 0