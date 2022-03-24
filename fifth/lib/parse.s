.scope parse
  pointer = $FD

  input:
  offset:
    .word 0
  eof:
    .byte 0
  error:
    .byte 0

  .proc reset 
    ISet offset, BUF
    CClear eof
    CClear error
    rts
  .endproc

  .proc advance_pointer
    inc pointer
    IfTrue skip
      inc pointer+1
    skip:
    rts
  .endproc

  .proc advance_offset
    IMov offset, pointer
    rts
  .endproc

  .proc reset_pointer
    IMov pointer,offset
    rts
  .endproc


  .proc skip_space 
    jsr reset_pointer
    ldx #0
    loop:
      lda (pointer,x)
      IfFalse stop
      IfEq #13, stop
      IfGe #33, done
      jsr advance_pointer
      jmp loop
    done:
      jsr advance_offset
      rts 
    stop:
      jsr advance_offset
      inc eof
      rts 
  .endproc

  .proc print_next_word
    jsr reset_pointer
    ldx #0
    loop:
      lda (pointer,x)
      IfLt #33, done
      jsr CHROUT
      jsr advance_pointer
      jmp loop
    done:
      rts 
  .endproc


  .proc next_word
    jsr reset_pointer
    ldx #0
    lda (pointer,x)
    IfNe #34, not_quoted
    quoted:
      jsr parse_string
      IfTrue error, not_found
      SpLoad
      PushFrom cursor
      rts
    not_quoted:
      IfNe #'$', not_hex
    hex:
      jsr parse_hex 
      IfTrue error, not_found
      SpLoad
      PushFrom cursor
      rts 
    not_hex:
      IfLt #'0', not_dec
      IfGe #'9'+1, not_dec
    decimal:
      jsr parse_dec
      IfTrue error, not_found
      SpLoad
      PushFrom cursor
      rts 
    not_dec:
    entry:
      jsr parse_entry
      IfTrue error, not_found
      jmp (cursor)
      rts 
    not_found:
      rts 
  .endproc



  .proc parse_hex
    IClear cursor
    jsr reset_pointer
    jsr advance_pointer
    ldx #0
    hex_digit:
      lda (pointer,x)
      and #$7f

      cmp #33
      bcc hex_done
      sub #$30
      bmi hex_error
      cmp #10
      bcc hex_found

      sec
      sbc #7
      cmp #9
      bcc hex_error
      cmp #16
      bcs hex_error

    hex_found:
      IShiftLeft cursor
      IShiftLeft cursor
      IShiftLeft cursor
      IShiftLeft cursor
      
      BCS hex_error
      
      ORA cursor
      STA cursor
      BCS hex_error
      jsr advance_pointer
      jmp hex_digit 

    hex_error:
      inc error
      rts 
    hex_done:
      jsr advance_offset
      rts 
  .endproc ; parse_hex



  .proc parse_dec
      IClear cursor
      jsr reset_pointer
      ldx #0
      dec_digit:
          lda (pointer,x)
          and #$7f
          
          IfLt #33, dec_done

          sub #'0'

          IfNeg dec_error
          IfGe #10, dec_error
          
          pha
            IMov temp, cursor
          pla

          IShiftLeft cursor
          IShiftLeft cursor
          
          pha
            IAdd cursor, temp
          pla

          IShiftLeft cursor

          BCS dec_error
          
          IAddA cursor 
          jsr advance_pointer
          jmp dec_digit

      dec_error:
          inc error
          rts 

      dec_done:
        jsr advance_offset
        rts 

      temp: .word 0
  .endproc ; parse_dec

  
  .proc parse_entry
      jsr vocab::reset_cursor
      match_entry:
        ldy #5
        jsr reset_pointer
        ldx #0

      next_char:
        lda (vocab::cursor),y
        beq end_entry       ; possible match, branch if zero terminator
        cmp (pointer,x)
        bne next_entry        ; no match
        jsr advance_pointer
        iny
        bne next_char

      next_entry: 
        jsr vocab::advance_cursor
        bne match_entry

      not_found:
        inc error
        rts

      end_entry:
        lda (pointer,x)
        IfGe #33, next_entry
        jsr advance_offset 
        rts 
  .endproc ; parse_entry

  .proc parse_string
    
    jsr advance_pointer
    ldy #0
    ldx #0
    IMov cursor, TOP
    
    parse_char:
      lda (pointer,x)
      IfLt #32, error
      IfEq #34, done
      sta (cursor),y
      jsr advance_pointer
      iny 
      bne parse_char
    error:
      inc error
      rts
    done:
      lda #0
      sta (cursor),y
      iny      
      jsr advance_pointer
      jsr advance_offset
      tya
      IAddA TOP
      
      rts
  .endproc    
.endscope