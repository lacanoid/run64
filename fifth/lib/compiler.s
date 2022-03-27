Pointer writer, HEAP_END

.scope compiler
  pointer = $FD
  IP = writer
  offset:
    .word 0
  eof:
    .byte 0
  error:
    .byte 0
  cstack:
    .res 128
  csp:
    .byte 0  
  
  .proc advance_pointer
    inc pointer
    IfTrue skip
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
      ;jsr input:read
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
    ;jsr input::read
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
          jmp die
          rts 

      dec_done:
        jsr advance_offset
        jmp write_int
      temp: .word 0
  .endproc ; parse_dec

  


  .proc parse_string
    lda #bytecode::tSTR
    jsr write
    Stash IP
    IAddB IP,2
    jsr advance_pointer
    ldx #0
    parse_char:
      ; jsr input::read
    
      lda (pointer,x)
      IfLt #32, error
      IfEq #34, done
      jsr write
      jsr advance_pointer
      bne parse_char
    error:
      jmp die
    done:
      jsr advance_pointer
      jsr advance_offset  
      lda #0
      jsr write
      Unstash cursor
      ldy #0
      lda IP
      sta (cursor),y
      lda IP+1
      iny
      sta (cursor),y
      rts
  .endproc    

  .proc parse_entry
      jsr vocab::reset_cursor
      match_entry:
        ldy #5
        jsr reset_pointer
        ldx #0

      next_char:
        lda (vocab::cursor),y
        beq end_entry       ; possible match, branch if zero terminator
        ; jsr input::read
    
        cmp (pointer,x)
        bne next_entry        ; no match
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
        IfGe #33, next_entry
        jsr advance_offset 
        IMov result, cursor
        ldy #0
        lda (cursor),y
        IfEq #bytecode::tCTL, write_cmd
        jmp write_run
  .endproc ; parse_entry


  .proc write
    ;jmp writer::write
    PokeA writer
    IInc writer
    ;pha
      ;jsr print::print_hex_digits
      ;PrintChr ' '
    ;pla
    rts
  .endproc    

  .proc write_int
      lda #bytecode::tINT
      jsr write
      jmp write_result
  .endproc

  .proc write_run
      lda #bytecode::tRUN
      jsr write
      jmp write_result
  .endproc

  .proc write_result 
      lda result
      jsr write
      lda result+1
      jsr write
      rts 
  .endproc

    .proc write_cmd
      RunFrom result
      rts 
    .endproc

  .proc write_if
      lda #bytecode::tIF
      jsr write
      lda #bytecode::tIF
      jsr cpush
      rts
  .endproc

  .proc write_else
      lda #bytecode::tPTR
      jsr write
      lda #2
      jsr cresolve
      jsr cdrop
      lda #bytecode::tPTR
      jsr cpush
      rts
  .endproc

  .proc write_then
      lda #0
      jsr cresolve
      jsr cdrop
      lda #bytecode::tTHEN
      jsr write
      rts
  .endproc


  .proc cpush
    ldx csp 
    inx
    inx
    inx
    stx csp
    jmp cset
  .endproc

  .proc cset
    ldx csp 
    sta cstack-3,x
    lda IP
    sta cstack-2,x
    lda IP+1
    sta cstack-1,x
    stx csp
    IAddB IP,2
    rts 
  .endproc

  .proc cresolve
    pha
    ldx csp
    
    lda cstack-2, x
    sta cursor 
    lda cstack-1, x
    sta cursor+1

    ldy #0
    pla
    clc
    adc IP
    sta (cursor),y 
    iny
    lda #0  
    adc IP+1
    sta (cursor),y 
    
    rts 
  .endproc

  .proc cdrop
    ldx csp
    dex
    dex
    dex 
    bmi catch
    rts 
    catch:
      jmp die
  .endproc

  
  .proc compile_skip_first
    ISet offset, BUF
    jsr reset_pointer
    jsr advance_pointer
    jsr advance_offset
    jmp do_compile
  .endproc

.proc compile
  ISet offset, BUF
.endproc    

.proc do_compile
    ISet IP, HEAP_START
    CClear eof
    CClear error
    CClear csp
  loop:
    jsr skip_space
    IfTrue eof, done
    
    jsr parse_word
    IfTrue error, catch
    jmp loop
  done:
    lda #bytecode::tRET
    jsr write
    lda #$12
    jsr write
    lda #$34
    jsr write
    lda csp
    ;jsr print::print_hex_digits
    
    rts
  catch:
    jmp die
  exit:
    rts
  .endproc

  .proc die
    inc error
    rts
  .endproc 

.endscope