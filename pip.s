; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.include "defs64.inc"
.include "macros.inc"

.forceimport __EXEHDR__

; test-result register exposed by VICE debugging 'cartridge'. Writing to this
; will cause VICE to exit, with the exit result set to the written value.

        pipfhi = 2
        pipfho = 3

start:
        jmp main

        rts

; -----------------------------------------------------------------------------
; variables
SIZE:   .word 0
FA1:    .byte 8
FNADR1: .word 0
FNLEN1: .byte 0   
FNLEN2: .byte 0

.include "utils.s"

; -----------------------------------------------------------------------------
; message table; last character has high bit set
MSGBAS  =*
MSG0:   .BYTE "PIP 0.3",13+$80
MSG1:   .BYTE "COPYING ",$80
MSG2:   .BYTE "ERROR ",$80
MSG3:   .BYTE " BYTES.",13+$80

; -----------------------------------------------------------------------------
; main program
main:
        lda BUF      ; if run from shell or basic
        bpl main1    ; check if basic token
        jmp main2    ; we were run from BASIC with "run"
main1:  lda COUNT    ; we were run from shell
        sta CHRPNT   ; restor command line pointer

        tax
        ldy #0

        JSR GOTCHR
        bne args
        jmp main2    ; no arguments

args:
        jsr GETFNADR
        bne @l2
        rts
@l2:
        jsr SETNAMX

        ldy #0
@l31:
        lda (FNADR),Y
        cmp #'='
        beq prep_copy
        iny
        cmp FNLEN
        bcs @l31
        jmp open_files

; separate source and destination names
; source becomes current file, destination goes to FNADR1 and FNLEN1
prep_copy:   
        lda FNLEN
        sty FNLEN1
        sec
        sbc FNLEN1
        sta FNLEN
        dec FNLEN
        sec
        lda FNADR
        sta FNADR1
        adc FNLEN1
        sta FNADR
        lda FNADR+1
        sta FNADR1+1
        adc #0
        sta FNADR+1

open_files:
        lda FNLEN
        sta FNLEN2
        beq @of1
        ; open input
        lda #pipfhi
        tay
        ldx FA
        jsr SETLFS
        jsr OPEN
        bcc @of1
        jmp error
        ; input opened        
@of1:
        ; open output
        lda FNLEN1
        beq redirect     ; no output

        LDY #MSG1-MSGBAS    ; display
        JSR SNDMSG
        jsr print_name
        jsr CRLF

        lda FNLEN1
        ldx FNADR1
        ldy FNADR1+1
        jsr SETNAMX

        lda #pipfho
        tay
        ldx FA
        jsr SETLFS
        jsr OPEN
        bcc redirect     ; succesful open

;        lda #'!'
;        jsr CHROUT

        jmp error
        ; output opened        

;        LDY #MSG1-MSGBAS    ; display copying...
;        JSR SNDMSG
;        JSR CRLF

redirect:
        ; set input
        lda FNLEN2
        beq @rdro
        ldx #pipfhi
        jsr CHKIN
@rdro:
        lda FNLEN1
        beq copy_loop
        ldx #pipfho
;        jsr CHKOUT

        ldy #0
copy_loop:
        jsr GETIN
        tax
        jsr READST
        bne feof

        ; enable quote mode
        ; most controls are displayed as reverse characters
        lda #$FF
        sta QTSW

        txa
        jsr CHROUT
        jsr READST
        bne feof

        inc SIZE
        bne @l1
        inc SIZE+1
@l1:

        jsr STOP
        bne copy_loop
        ; stop pressed

feof:
        AND #$BF
        beq done
        jsr error

done:
        jsr finish
        jsr CRLF

        ; print byte count
        ldx SIZE
        lda SIZE+1
        jsr LINPRT
        LDY #MSG3-MSGBAS    ; display
        JSR SNDMSG

        rts

@l3:    lda BUF,X
        beq main2
        jsr CHROUT
        inx
        cpx #80
        bne @l3
main2:
        LDY #MSG0-MSGBAS    ; display
        JSR SNDMSG
        ; interactive mode here,,,
        rts

finish:
        jsr CLRCHN
        lda #pipfhi
        jsr CLOSE
        lda #pipfho
        jsr CLOSE
        rts

error:
        jsr finish
        jsr print_name
        LDY #MSG2-MSGBAS    ; display
        JSR SNDMSG
        jsr READST
        jsr WRTWO
        jsr INSTAT
        rts

; -----------------------------------------------------------------------------
; set filename and optional device number 
SETNAMX:
        jsr SETNAM
        ldy #1
        lda (FNADR),Y
        cmp #':'
        bne @done
        DEY
        lda (FNADR),y
        jsr SETDEV
        beq @done
        clc
        lda FNADR
        adc #2
        sta FNADR
        lda FNADR+1
        adc #0
        sta FNADR+1
        dec FNLEN
        dec FNLEN
@done:
        rts

; -----------------------------------------------------------------------------
; set device in .a
SETDEV:
        cmp #'0'
        bcc @sde
        cmp #64
        bcs @sd2
        sbc #'0'-1
        bpl @sdx
@sd2:
        sbc #64-9
        bpl @sdx
@sde:
        lda 0
        rts
@sdx:
        sta FA
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
        pha
        tya
        pha
        lda #'"'
        jsr CHROUT
        ldy #0
@p1:    lda (FNADR),y
        jsr CHROUT
        iny
        cpy FNLEN
        bne @p1
        lda #'"'
        jsr CHROUT
        lda #' '
        jsr CHROUT
        pla
        tay
        pla
        rts
