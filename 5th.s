cursor = $FB

.include "defs64.inc"

    jmp main

input = BUF

_dbottom:

blue:
    .word red
    .asciiz "BLUE"
    LDA #14
    STA COLOR
    jsr banner
    RTS

red:
    .word brown
    .asciiz "RED"
    LDA #2
    STA COLOR
    jsr banner
    RTS

brown:
    .word 0 
    .asciiz "BROWN"
    LDA #10
    STA COLOR
    jsr banner
    RTS

interpret:
    lda #0
    sta eof
@i1:
    jsr next_word
    lda eof
    beq @i1
    rts

next_word:

    ldx offset
    skip_space:
        lda input,x
        bne @ss1
    @ss2:
        inc eof
        rts
    @ss1:
        cmp #13
        beq @ss2
        cmp #33
        bcs skipped_space
        inx
        jmp skip_space
    skipped_space:
        stx offset

    lda dbottom
    sta cursor
    lda dbottom+1
    sta cursor+1

    match_entry:
        ldy #2
        ldx offset

        next_char:
            lda (cursor),y
            beq end_entry       ; possible match, branch if zero terminator
            cmp input,x 
            bne next_entry        ; no match
            inx
            iny
            bne next_char

        error:
            ; ERROR PANIC
            rts

    next_entry: 
        ldy #0
        lda (cursor),y
        tax
        iny 
        lda (cursor),y
        
        stx cursor
        sta cursor+1

        bne match_entry

        not_found:
            lda #'?'
            jsr CHROUT
            ; report not found
            rts

    end_entry:
        lda input,x
        lda input,x
        cmp #33
        bcs next_entry
    found:
        iny
        stx offset 
        tya
        clc
        adc cursor
        sta cursor
        bcc @f1
        inc cursor+1
    @f1:
        lda #'!'
        jsr CHROUT
;        jsr debug
        jmp (cursor)
        rts

main:
    jsr getinput
    jsr CRLF
    jsr interpret
    jsr CRLF
    jmp main
    rts

debug:
    lda cursor+1
    jsr WRTWO
    lda cursor
    jsr WRTWO
    rts

getinput:
        ldx #0
        stx offset
SMOVE:  jsr CHRIN
        sta BUF,X
        inx
        CPX #ENDIN-BUF   ; error if buffer is full
        BCS ierror
        cmp #13             ; keep reading until CR
        bne SMOVE
        LDA #0              ; null-terminate input buffer
        STA BUF-1,X         ; (replacing the CR)
        rts

ierror:
    LDY #MSG1-MSGBAS
    JSR SNDMSG    
    rts

banner:
    LDY #MSG2-MSGBAS
    JSR SNDMSG    
    rts

.include "utils.s"
; -----------------------------------------------------------------------------
; message table; last character has high bit set
MSGBAS  =*
MSG0:   .BYTE "5TH 0.1",13+$80
MSG1:   .BYTE "INPUT ERROR ",13+$80
MSG2:   .BYTE "****",13+$80


offset:
    .byte 0

dbottom:
    .word _dbottom

eof:
    .byte 0
