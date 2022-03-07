; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.include "defs64.inc"
.include "macros.inc"

.forceimport __EXEHDR__

; test-result register exposed by VICE debugging 'cartridge'. Writing to this
; will cause VICE to exit, with the exit result set to the written value.

        pipfh = 2

start:
        jmp main

        rts

.include "utils.s"

; -----------------------------------------------------------------------------
; message table; last character has high bit set
MSGBAS  =*
MSG0:   .BYTE 14
        .BYTE "PIP 0.2",13+$80
MSG1:   .BYTE 14
        .BYTE "COPYING... ",$80
MSG2:   .BYTE 14
        .BYTE "ERROR ",$80

; -----------------------------------------------------------------------------
; main program
main:
        lda BUF      ; if run from shell or basic
        bpl main1    ; check if basic token
        jmp main2    ; we were run from BASIC with "run"
main1:  lda COUNT
        sta CHRPNT

        tax
        ldy #0

        JSR GOTCHR
        beq main2    ; no arguments

        jsr GETFNADR
        bne @l2
        rts
@l2:
        jsr SETNAM

;        jsr print_name

        lda #pipfh
        ldx FA
        ldy #pipfh
        jsr SETLFS

        jsr OPEN
        bcs error
        
;        LDY #MSG1-MSGBAS    ; display copying...
;        JSR SNDMSG
;        JSR CRLF

        ldx #pipfh
        jsr CHKIN
        
@loop:
        jsr GETIN
        tax
        jsr READST
        bne @eof
        txa
        jsr CHROUT
        jsr STOP
        bne @loop
        ; stop pressed
@eof:
        AND #$BF
        beq @done
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
        LDY #MSG0-MSGBAS    ; display
        JSR SNDMSG

        rts

error:
        LDY #MSG2-MSGBAS    ; display
        JSR SNDMSG
        jsr READST
        jsr WRTWO
        jsr INSTAT
        rts

; -----------------------------------------------------------------------------
; display disk error
INSTAT: 
        JSR CLRCHN
        lda #0
        sta STATUS
        JSR UNLSN           ; command device to unlisten
INSTAT1:JSR CRLF            ; new line
        LDA FA              ; load device address
        JSR TALK            ; command device to talk
        LDA #$6F            ; secondary address 15 (only low nybble used)
        JSR TKSA
RDSTAT: JSR ACPTR           ; read byte from serial bus
        JSR CHROUT          ; print it
        CMP #$0D            ; if the byte is CR, exit loop
        BEQ DEXIT
        LDA STATUS           ; check status
        AND #$BF            ; ignore EOI bit
        BEQ RDSTAT          ; if no errors, read next byte
DEXIT:  JSR UNTLK           ; command device to stop talking
        RTS

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
