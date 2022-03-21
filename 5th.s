.include "defs64.inc"
cursor = $FB
input = BUF
TMP = $FD
.macro PUSH arg
    ldx SP
    lda #<arg
    sta STACK,x
    inx
    lda #>arg
    sta STACK,x
    inx
    stx SP 
.endmacro

.macro chrout char
    pha
    lda #char
    jsr CHROUT
    pla
.endmacro

jmp main

_dbottom:

.macro entry name
    .word next
    .asciiz name
.endmacro

.proc INK
    entry "INK"
    PUSH $286
    rts
    next:
.endproc

.proc POKE
    entry "POKE"
    ldx SP
    lda STACK-4,x
    sta TMP
    lda STACK-3,x
    sta TMP+1
    lda STACK-2,x
    ldy #0
    sta (TMP),y
    dex
    dex
    dex
    dex
    stx SP
    rts
    next:
.endproc

.proc PEEK
    entry "PEEK"
    ldx SP
    lda STACK-2,x
    sta TMP
    lda STACK-1,x
    sta TMP+1
    lda #0
    tay
    sta STACK-1,x
    lda (TMP),y
    sta STACK-2,x
    rts
    next:
.endproc

.proc ADD 
    entry "+"

    ldx SP
    lda STACK-2,x
    clc 
    adc STACK-4,x
    sta STACK-4,x
    lda STACK-3,x
    adc STACK-1,x
    sta STACK-3
    dex
    dex
    stx SP 
    rts
    next:
.endproc

.proc DEPTH
    entry "DEPTH"
    lda SP
    clc 
    ror
    jsr WRTWO
    rts
    next:
.endproc

.proc PRINT
    entry "."

    lda #'$'
    jsr CHROUT
    ldx SP
    dex
    lda STACK,x
    jsr WRTWO
    dex
    lda STACK,x
    jsr WRTWO
    stx SP
    rts
    next=0
.endproc

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

    lda input,x
    cmp #'$'
    bne find_entry
        jsr match_hex 
        rts
    find_entry:
        jsr match_entry
        rts 

match_hex:
    lda #0
    sta hex_result
    sta hex_result+1

    hex_digit:

        inx

        lda input,x
        and #$7f
        
        lda input,x
        and #$7f
        
        cmp #33
        bcc hex_done

        sec 
        sbc #$30
        bmi hex_error
        cmp #10
        bcc hex_found

        sec
        sbc #7
        cmp #9
        bcc hex_error
        cmp #15
        bcs hex_error

    hex_found:
        ASL hex_result
        ROL hex_result+1
        ASL hex_result
        ROL hex_result+1
        ASL hex_result
        ROL hex_result+1
        ASL hex_result
        ROL hex_result+1
        BCS hex_error
        
        ORA hex_result
        STA hex_result
        BCC hex_digit

    hex_error:
        lda #'$'
        jsr CHROUT
        lda #'?'
        jsr CHROUT
        lda input,x
        jsr CHROUT
        inc eof
        rts 

    hex_done:
        stx offset

        ldx SP
        lda hex_result
        sta STACK,x
        inx 
        lda hex_result+1
        sta STACK,x
        inx 
        stx SP 

        lda #'$'
        jsr CHROUT
        lda hex_result+1
        jsr WRTWO
        lda hex_result
        jsr WRTWO
        jsr CRLF

        rts 




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
            inc eof
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
            inc eof
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

hex_result: .word 0

SP: .byte 0
STACK: .res 256
