; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.include "defs64.inc"
.include "macros.inc"

.forceimport __EXEHDR__

; test-result register exposed by VICE debugging 'cartridge'. Writing to this
; will cause VICE to exit, with the exit result set to the written value.

MAIN:
        LDY #MSG0-MSGBAS    ; display
        JSR SNDMSG

; copy
        leaxy $A000 ; copy basic
        stxy T1     ; set address
        ldx #32     ; number of pages top copy
        jsr copy

        leaxy $E000 ; copy kernal
        stxy T1     ; set address
        ldx #32     ; number of pages top copy
        jsr copy

        lda 1       ; switch kernel and basic roms out
        and #$FD
        sta 1

; patch 
        ldx #5      ; change ready prompt to something else
@l1:    lda prompt,x
        sta $a378,x
        dex
        bpl @l1

        ; change default memory configuraton in R6510
        LDA #%11100101
        STA $FDD5+1   ; 

        ; set default colors and device number
        lda EXTCOL
        sta $ecd9     ; border color
        lda BGCOL0
        sta $ecda     ; backgorund color
        lda COLOR
        sta $e534+1   ; foreground color
        lda FA
        sta $e1d9+1   ; default device number for BASIC LOAD

        ; patch ramtas
        ldx #6
@l2:    lda ramtas2,X
        sta $fd79,X
        dex
        bpl @l2

        LDY #MSG1-MSGBAS    ; display
        JSR SNDMSG

        rts

prompt:
        .byte "RUN64."

ramtas2:
        .byte $a5,$c2,$c9,$a0,$f0,$09,$ea

; -----------------------------------------------------------------------------
; copy pages
copy:
        ldy #0
@loop1:
        LDA (T1),Y
        STA (T1),Y
        INY
        BNE @loop1
        dex
        beq @end1
        inc T2
        bne @loop1
@end1:
        RTS

; -----------------------------------------------------------------------------
; display message from table
SNDMSG: LDA MSGBAS,Y        ; Y contains offset in msg table
        PHP
        AND #$7F            ; strip high bit before output
        JSR CHROUT
        INY
        PLP
        BPL SNDMSG          ; loop until high bit is set
        RTS

; -----------------------------------------------------------------------------
; message table; last character has high bit set
MSGBAS  =*
MSG0:   .BYTE 14
        .BYTE "PATCH64",' '+$80
MSG1:   .BYTE 14
        .BYTE "COPYING ROM TO RAM",' '+$80
