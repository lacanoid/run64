; C64 program autostarter
; Copyright 2018, Richard Halkyard <rhalkyard@gmail.com>
; Copyright 2020, Ziga Kranjec <lacanoid@ljudmila.org>

.include "config.inc"
.include "defs64.inc"
.include "macros.inc"
.include "boot.inc"

.import __AUTOSTART64_SIZE__, __AUTOSTART64_LOAD__, __AUTOSTART64_RUN__
.import __CARTHDR_LOAD__, __CARTHDR_RUN__, __CARTHDR_SIZE__

.segment "CARTHDR"
        ; cartridge header
        .addr hardrst   ; hard reset vector
        .addr $fe5e     ; soft reset vector: return to NMI handler immediately after cartridge check
        .byte $C3, $C2, $CD, $38, $30   ; 'CBM80' magic number for autostart cartridge

; config parameters
bootctl:.byte 0        ; boot control
bootbgc:.byte 1        ; background color
bootfgc:.byte 0        ; foreground color
bootexc:.byte 14       ; border color

; SXREG   = $030D  ; Storage Area for .X Index Register
; INDEX1  = $22    ; (2) ???

hardrst: 
        STX $D016       ; modified version of RESET routine (normally at $FCEF-$FCFE)
        JSR IOINIT

        lda FA          ; preserve last device number
        pha
        lda EAL         ; and end-of program address
        pha
        lda EAL+1
        pha
        JSR RAMTAS
        JSR RESTOR
        pla
        sta EAL+1
        pla
        sta EAL
        pla
        sta FA

; restore segment AUTOSTART64 from VICAS64 to TBUFFER
restoreas64:
copy:   
;        txa
;        tay
        LDX  #< (__AUTOSTART64_SIZE__ + 1)
@loop:  LDA VICAS64 -1, X 
        STA __AUTOSTART64_RUN__ - 1, X
        DEX
        BNE @loop
;        tya 
;        tax
;bootscr_data:
        jmp init2

.segment "AUTOSTART64"
        jmp old
        jmp old2

; continue initializaton 
init2:
        JSR CINT        ; video init

; restore colors  
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

        jsr restorecrtb ; restore memory overwrittent by cartridge
        CLI

        JSR $E453       ; modified version of BASIC cold-start (normally at $E394-$E39F)
        JSR $E3BF
        JSR $E422
        LDX #$FB
        TXS
        ; normally the main BASIC loop starts here, but we have more work to do ;)

print:  LDX #$00        ; Print load/run commands to screen
@loop:  LDA cmds, X
        BEQ @done
        JSR CHROUT
        INX
        BNE @loop
@done:
        jmp old

;kbdinj: LDX #$00        ; Inject stored keystrokes into keyboard buffer
;@loop:  LDA keys, X
;        BEQ @done
;        STA KEYD, X
;        INC NDX
;        INX
;        BNE @loop
;@done:
 
;        LDA #<bootmsg
;        LDY #>bootmsg
;        JMP $A478       ; jump into BASIC

; restore basic program after reset, un-new
; these two must be called from basic as SYS820:SYS823:CLR or such
old:    lda #1
        sta 2050
        jsr LINKPRG
;        rts
old2:   
        ldxy EAL
        stxy VARTAB

;        rts
        jsr RUNC
        jsr STXTPT
        jmp NEWSTT

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
        .BYTE CR, 0

; keys:   .byte CR, CR, CR, 0 ; keystrokes to inject into keyboard buffer
