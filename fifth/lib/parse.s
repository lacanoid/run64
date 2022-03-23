
.proc parse_hex
  lda #0
  sta cursor
  sta cursor+1

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
    ASL cursor
    ROL cursor+1

    ASL cursor
    ROL cursor+1

    ASL cursor
    ROL cursor+1

    ASL cursor
    ROL cursor+1

    BCS hex_error
    
    ORA cursor
    STA cursor
    BCC hex_digit

  hex_error:
    inc f_error
    rts 
  hex_done:
    stx offset
    rts 
.endproc ; parse_hex

.proc parse_dec
    lda #0
    sta cursor
    sta cursor+1
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
        lda cursor
        sta temp
        lda cursor+1
        sta temp+1
        pla

        ASL cursor
        ROL cursor+1
        ASL cursor
        ROL cursor+1

        pha
        clc
        lda cursor
        adc temp
        sta cursor
        lda cursor+1
        adc temp+1
        sta cursor+1
        pla

        ASL cursor
        ROL cursor+1

        BCS dec_error
        nomul:
        ADC cursor
        
        STA cursor
        BCC dec_digit

    dec_error:
        inc f_error
        rts 

    dec_done:
      stx offset
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

    next_entry: 
      jsr vocab__advance_cursor
      bne match_entry

    not_found:
      inc f_error
      rts

    end_entry:
      lda input,x
      cmp #33
      bcs next_entry
      stx offset 
      rts 
.endproc ; parse_entry
