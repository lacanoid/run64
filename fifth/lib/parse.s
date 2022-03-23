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
    iSet offset, BUF
    bClear eof
    bClear error
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
    iMov offset, pointer
    rts
  .endproc

  .proc reset_pointer
    iMov pointer,offset
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
      NewLine
      rts 
  .endproc


  .proc next_word
      jsr reset_pointer
      lda (pointer,x)
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
    iClear cursor
    jsr reset_pointer
    ldx #0
    hex_digit:
      lda (pointer,x)
      and #$7f
      jsr advance_pointer
      
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
      iShiftLeft cursor
      iShiftLeft cursor
      iShiftLeft cursor
      iShiftLeft cursor
      
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
      iClear cursor
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
            iMov temp, cursor
          pla

          iShiftLeft cursor
          iShiftLeft cursor
          
          pha
            iAdd cursor, temp
          pla

          iShiftLeft cursor

          BCS dec_error
          nomul:
          ADC cursor
          
          STA cursor
          BCS dec_error
          jsr advance_pointer
          jmp dec_digit

      dec_error:
          inc error
          rts 

      dec_done:
        jsr advance_offset
        rts 

      temp: .word 0
  .endproc ; parse_hex

  
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
.endscope