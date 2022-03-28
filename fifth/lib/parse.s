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
    BraTrue skip
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
      BraFalse stop
      BraEq #13, stop
      BraGe #33, done
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
      BraLt #33, done
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
    BraNe #34, not_quoted
    quoted:
      jsr parse_string
      BraTrue error, not_found
      
      PushFrom cursor
      rts
    not_quoted:
      BraNe #'$', not_hex
    hex:
      jsr parse_hex 
      BraTrue error, not_found
      
      PushFrom cursor
      rts 
    not_hex:
      BraLt #'0', not_dec
      BraGe #'9'+1, not_dec
    decimal:
      jsr parse_dec
      BraTrue error, not_found
      
      PushFrom cursor
      rts 
    not_dec:
    entry:
      jsr parse_entry
      BraTrue error, not_found
      ldy #0
      lda (cursor),y
      beq run_entry
      jmp (cursor)
      rts 
      run_entry:
        IMov runtime::IP, cursor
        jsr runtime::run
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
          
          BraLt #33, dec_done

          sub #'0'

          BraNeg dec_error
          BraGe #10, dec_error
          
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
        ldy vocab::name_offset
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
        BraGe #33, next_entry
        jsr advance_offset 
        rts 
  .endproc ; parse_entry

  .proc parse_string
    
    jsr advance_pointer
    ldy #0
    ldx #0
    IMov cursor, HEAP_END
    
    parse_char:
      lda (pointer,x)
      BraLt #32, error
      BraEq #34, done
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
      IAddA HEAP_END
      
      rts
  .endproc    
.endscope