; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.include "defs64.inc"
.include "macros.inc"

.forceimport __EXEHDR__

; test-result register exposed by VICE debugging 'cartridge'. Writing to this
; will cause VICE to exit, with the exit result set to the written value.

        pipfh = 2

start:
        LDY #MSG0-MSGBAS    ; display
        JSR SNDMSG

        jmp main

        rts

.include "utils.s"

; -----------------------------------------------------------------------------
; message table; last character has high bit set
MSGBAS  =*
MSG0:   .BYTE 14
        .BYTE "PIP 0.1",13+$80
MSG1:   .BYTE 14
        .BYTE "COPYING... ",$80
MSG2:   .BYTE 14
        .BYTE "ERROR ",$80

; -----------------------------------------------------------------------------
; main program
main:
        lda BUF      ; if run from shell or basic
        bpl main1    ; check if basic token
        rts          ; we were run from BASIC with "run"
main1:  lda COUNT
        sta CHRPNT

        tax
        ldy #0

        JSR GOTCHR
        beq main2

        jsr GETFNADR
        bne @l2
        rts
@l2:
        jsr SETNAM

        jsr print_name

        lda #pipfh
        ldx FA
        ldy #pipfh
        jsr SETLFS

        jsr OPEN
        bcs error
        
        LDY #MSG1-MSGBAS    ; display
        JSR SNDMSG

        ldx #pipfh
        jsr CHKIN
        
@loop:  jsr READST
        bne @eof
        jsr GETIN
        jsr CHROUT
        jsr STOP
        bne @loop
        ; stop pressed
@eof:
        jsr error

@done:
        jsr CLRCHN
        lda #pipfh
        jsr CLOSE
        rts

@l1:    lda BUF,X
        beq main2
        jsr CHROUT
        inx
        cpx #80
        bne @l1
main2:
        rts

error:
        LDY #MSG2-MSGBAS    ; display
        JSR SNDMSG
        jsr READST
        jsr WRTWO
        jsr CRLF
        rts

; -----------------------------------------------------------------------------
; main program
print_name:
        ldy #0
@p1:    lda (FNADR),y
        jsr CHROUT
        iny
        cpy FNLEN
        bne @p1
        lda #' '
        jsr CHROUT
        rts
