
.proc parse_hex
    lda #0
    sta hex_result
    sta hex_result+1

    hex_digit:

        inx

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
        rts 

.endproc ; parse_hex

.proc parse_dec
    lda #0
    sta hex_result
    sta hex_result+1
    dex
    dec_digit:

        inx

        lda input,x
        and #$7f
        
        cmp #33
        bcc dec_done

        sec 
        sbc #$30
        bmi dec_error
        cmp #10
        bcs dec_error

        pha
        lda hex_result
        sta temp
        lda hex_result+1
        sta temp+1
        pla

        ASL hex_result
        ROL hex_result+1
        ASL hex_result
        ROL hex_result+1

        pha
        clc
        lda hex_result
        adc temp
        sta hex_result
        lda hex_result+1
        adc temp+1
        sta hex_result+1
        pla

        ASL hex_result
        ROL hex_result+1

        BCS dec_error
        nomul:
        ADC hex_result
        
        STA hex_result
        BCC dec_digit

    dec_error:
        lda #'0'
        jsr CHROUT
        lda #'?'
        jsr CHROUT
        lda input,x
        jsr CHROUT
        inc eof
        rts 

    dec_done:
        stx offset

        ldx SP
        lda hex_result
        sta STACK,x
        inx 
        lda hex_result+1
        sta STACK,x
        inx 
        stx SP 
        rts 

    temp: .word 0
.endproc ; parse_hex


.proc parse_entry
    jsr vocab__reset_cursor

    match_entry:

        ldy #5
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
        jsr vocab__advance_cursor
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
        
    @f1:
        jmp (cursor)
        rts 
.endproc ; parse_entry
