.macro cWriteCtl
  jsr compiler::write_ctl
.endmacro

.macro cWriteRun
  jsr compiler::write_run
.endmacro

.macro cWriteHope arg
  lda #bytecode::arg 
  jsr compiler::write_hope
.endmacro

.macro cResolveHope arg, offset
  .ifblank offset
    ldy #0
  .else   
    ldy #offset
  .endif
  lda #bytecode::arg 
  jsr compiler::resolve_hope
.endmacro

.macro cDrop
  jsr compiler::cdrop
.endmacro


.macro cStoreRef arg
  lda #bytecode::arg
  jsr compiler::store_ref
.endmacro

.macro cWriteRef arg
  lda #bytecode::arg
  jsr compiler::write_ref
.endmacro

  writer: .word  HEAP_END

  .scope compiler
  pointer = $FD
  CP = writer
  offset:
    .word 0
  eof:
    .byte 0
  error:
    .byte 0
  cstack:
    .res 72
  csp:
    .byte 0 
  ctop:
    .byte 3
  result: .word 0

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
    lda #bytecode::CTL
    jsr write
    lda #<cSTR
    jsr write
    lda #>cSTR
    jsr write
    cWriteHope STR
    jsr advance_pointer ; consume start quote
    ldx #0
    Begin
    ; jsr input::read
    lda (pointer,x)
    BraLt #32, catch
    BraEq #34, break
    jsr write
    jsr advance_pointer
    Again
    jsr advance_pointer ; consume end quote
    jsr advance_offset  
    lda #0
    jsr write       ; write terminating zero
    cResolveHope STR
    cDrop
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
      jmp write_entry
  .endproc ; parse_entry

  .proc write_entry
    ;IPrintHex result
    PeekA result, vocab::compile_offset
    sta rewrite+1
    PeekA result, 1+vocab::compile_offset
    sta rewrite+2
    rewrite:
    jmp $FEDA
  .endproc

  .proc write
    WriteA CP
    rts
  .endproc  

  .proc write_int
    lda #bytecode::CTL
    jsr write
    lda #<cINT
    jsr write
    lda #>cINT
    jsr write
    jmp write_result
  .endproc

  .proc write_run
    lda #bytecode::RUN
    jsr write
    jmp write_result
  .endproc

  .proc write_ctl
    lda #bytecode::CTL
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

  .proc write_hope
    jsr store_ref
    IAddB CP,2
    rts 
  .endproc

  .proc store_ref
    ldx csp 
    inx
    inx
    inx
    sta cstack-3,x
    lda CP
    sta cstack-2,x
    lda CP+1
    sta cstack-1,x
    stx csp
    ;PrintChr '+'
    rts 
  .endproc


  .proc resolve_hope
    ldx csp
    beq catch

    cmp cstack-3, x
    bne catch

    IMov temp, CP
    tya 
    IAddA temp
    Stash CP
      IMovIx CP, cstack-2,csp
      lda temp
      jsr write
      lda temp+1
      jsr write
    Unstash CP
    clc
    rts
    catch:
    sec
    rts
    temp: .word 0
  .endproc

  .proc write_ref
    ldx csp
    beq catch
    cmp cstack-3, x
    bne catch

    lda cstack-2, x
    jsr write
    ldx csp
    lda cstack-1, x
    jsr write
    clc
    rts 
    catch:
    sec
    rts 
  .endproc

  .proc cdrop
    ldx csp
    txa
    beq catch
    dex
    dex
    dex
    stx csp
    ;PrintChr '-'
    rts 
    catch:
    jmp lmismatch
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
  ISet CP, HEAP_START
  CClear eof
  CClear error
  CClear csp
  Begin
    jsr skip_space
    BraTrue eof, break
    
    jsr parse_word
    BraTrue error, catch
  Again
  lda #bytecode::CTL
  jsr write
  lda #<cRET
  jsr write
  lda #>cRET
  jsr write
  
  lda csp
  bne rmismatch

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

  .proc lmismatch
    ColorSet 2
    PrintChr '?'
    PrintName result
    lda csp
    jsr print::print_hex_digits
    PrintChr '('
    inc error
    rts
  .endproc

  .proc rmismatch
    ColorSet 2
    PrintChr '?'
    lda csp
    jsr print::print_hex_digits
    PrintChr ')'
    inc error
    rts
  .endproc
  .endscope
