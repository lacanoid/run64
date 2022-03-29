  .scope parser
    INPUT = BUF
    result = codegen::result

    .proc advance_pointer
      inc pointer
      BraTrue skip
      inc pointer+1
      skip:
      rts
    .endproc

    .proc advance_offset
      ;IMov offset, input::ptr
      IMov offset, pointer
      rts
    .endproc

    .proc reset_pointer
      ;IMov offset, input::ptr
      IMov pointer,offset
      rts
    .endproc


    .proc skip_space 
      jsr reset_pointer
      ldx #0
      loop:
      ;jsr input::read
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
      Begin
      ;jsr input:read
      lda (pointer,x)
      BraLt #33, break
      jsr CHROUT
      jsr advance_pointer
      Again
      rts 
    .endproc


    .proc parse_word
      jsr reset_pointer
      ;jsr input::read
      ldx #0
      lda (pointer,x)
      JmpEq #34, parse_string
      JmpEq #'$', parse_hex
      BraLt #'0', not_dec
      BraGe #'9'+1, not_dec
      decimal:
      jmp parse_dec
      not_dec:
      entry:
      jmp parse_entry
    .endproc

    .proc parse_hex
      IClear result
      jsr reset_pointer
      jsr advance_pointer
      ldx #0
      hex_digit:
      ; jsr input::read
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
      jmp die
      hex_done:
      jsr advance_offset
      jmp write_int
    .endproc ; parse_hex

    .proc parse_dec
      IClear result
      jsr reset_pointer
      ldx #0
      dec_digit:
      
        ; jsr input::read
        lda (pointer,x)
        and #$7f
        
        BraLt #33, dec_done

        sub #'0'

        BraNeg dec_error
        BraGe #10, dec_error
        
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
        jmp die
        rts 

      dec_done:
        jsr advance_offset
        jmp write_int
      temp: .word 0
    .endproc ; parse_dec

    


    .proc parse_string
      lda #bytecode::STR
      jsr codegen::write
      lda #bytecode::STR
      jsr codegen::write_hope

      jsr advance_pointer ; consume start quote
      ldx #0
      Begin
      ; jsr input::read
      lda (pointer,x)
      BraLt #32, catch
      BraEq #34, break
      jsr codegen::write
      jsr advance_pointer
      Again
      jsr advance_pointer ; consume end quote
      jsr advance_offset  

      lda #0
      jsr write       ; write terminating zero


      lda #bytecode::STR
      ldy #0
      jsr codegen::resolve_hope
      bcs catch 
      rts   
      catch:
      jmp die
    .endproc  

    .proc parse_entry
      jsr vocab::reset_cursor
      match_entry:
        ldy #vocab::name_offset
        jsr reset_pointer
        ldx #0

      next_char:
        lda (vocab::cursor),y
        beq end_entry     ; possible match, branch if zero terminator
        ; jsr input::read
      
        cmp (pointer,x)
        bne next_entry    ; no match
        jsr advance_pointer
        iny
        bne next_char

      next_entry: 
        jsr vocab::advance_cursor
        bne match_entry

      not_found:
        jmp die

      end_entry:
        lda (pointer,x)
        BraGe #33, next_entry
        jsr advance_offset 
        IMov result, cursor
        ldy #vocab::token_offset
        lda (cursor),y
        BraEq #bytecode::CTL, codegen::write_ctl
        jmp codegen::write_run
    .endproc ; parse_entry
  .proc lmismatch
    PrintChr ' '
    ColorSet 2
    lda csp
    jsr print::print_hex_digits
    PrintChr '('
    inc error
    rts
  .endproc

  .proc rmismatch
    PrintChr ' '
    ColorSet 2
    lda csp
    jsr print::print_hex_digits
    PrintChr ')'
    inc error
    rts
  .endproc
.endscope
