; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.include "defs64.inc"
.include "macros.inc"

.forceimport __EXEHDR__

; test-result register exposed by VICE debugging 'cartridge'. Writing to this
; will cause VICE to exit, with the exit result set to the written value.

start:
        LDY #MSG0-MSGBAS    ; display
        JSR SNDMSG

        jsr main

        rts

; -----------------------------------------------------------------------------
; load extra patches specified on the command line
main:
        lda BUF      ; if run from shell or basic
        bpl main1    ; check if basic token
        rts          ; we were run from BASIC with "run"
main1:  lda COUNT
        sta CHRPNT

        tax
        ldy #0

@l1:    lda BUF,X
        beq main2
        jsr CHROUT
        inx
        cpx #80
        bne @l1
main2:
        rts
        
.include "utils.s"

; -----------------------------------------------------------------------------
; message table; last character has high bit set
MSGBAS  =*
MSG0:   .BYTE 14
        .BYTE "PIP 0.1",' '+$80
MSG1:   .BYTE 14
        .BYTE "COPYING... ",$80
