.scope compiler
  pointer = $FD

  input:
  offset:
    .word 0
  eof:
    .byte 0
  error:
    .byte 0

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


  .proc parse_word
    jsr reset_pointer
    ldx #0
    lda (pointer,x)
    
    IfNe #34, not_quoted
    quoted:
      jmp parse_string
    not_quoted:
      IfNe #'$', not_hex
    hex:
      jmp parse_hex 
    not_hex:
      IfLt #'0', not_dec
      IfGe #'9'+1, not_dec
    decimal:
      jmp parse_dec
    not_dec:
    entry:
      jmp parse_entry
  .endproc
  result: .word 0

  .proc parse_hex
    IClear result
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
      IShiftLeft result
      IShiftLeft result
      IShiftLeft result
      IShiftLeft result
      
      BCS hex_error
      
      ORA result
      STA result
      BCS hex_error
      jsr advance_pointer
      jmp hex_digit 

    hex_error:
      inc error
      rts 
    hex_done:
      jsr advance_offset
      jmp write_int
  .endproc ; parse_hex

  .proc parse_dec
      IClear result
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
            IMov temp, result
          pla

          IShiftLeft result
          IShiftLeft result
          
          pha
            IAdd result, temp
          pla

          IShiftLeft result

          BCS dec_error
          
          IAddA result 
          jsr advance_pointer
          jmp dec_digit

      dec_error:
          inc error
          rts 

      dec_done:
        jsr advance_offset
        jmp write_int
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
        IMov result, cursor
        jmp write_run
  .endproc ; parse_entry

  .proc parse_string
    lda #runtime::_STR
    jsr write
    Stash HEAP_END
    IAddB HEAP_END,2
    jsr advance_pointer
    ldx #0
    parse_char:
      lda (pointer,x)
      IfLt #32, error
      IfEq #34, done
      jsr write
      jsr advance_pointer
      bne parse_char
    error:
      inc error
      rts
    done:
      jsr advance_pointer
      jsr advance_offset  
      lda #0
      jsr write
      Unstash cursor
      ldy #0
      lda HEAP_END
      sta (cursor),y
      lda HEAP_END+1
      iny
      sta (cursor),y
      
      rts
  .endproc    

  .proc write 
    pha
    IMov cursor, HEAP_END
    ldx #0
    pla
    sta (cursor,x)
    inc HEAP_END
    rts
  .endproc    

  .proc write_int
      lda #runtime::_INT
      jmp write_result
  .endproc

.proc write_run
      lda #runtime::_RUN
      jmp write_result
  .endproc

  .proc write_result 
      jsr write
      lda result
      jsr write
      lda result+1
      jsr write
      rts 
  .endproc


.proc compile
    ISet offset, BUF
    ISet HEAP_END, HEAP_START
    CClear eof
    CClear error
  loop:
    jsr skip_space
    IfTrue eof, done
    
    jsr parse_word
    IfTrue error, catch
    jmp loop
  done:
    lda #runtime::_RET
    jsr write
    ColorPush 3
    PrintChr 'O'
    PrintChr 'K'
    ColorPop
    rts
  catch: 
    ColorPush 10
    PrintChr '?'
    jsr print_next_word
    ColorPop
    rts 
.endproc

.endscope