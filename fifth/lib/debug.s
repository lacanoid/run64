
.scope debug
  IP = runtime::IP
  ::LP = IP

  cIP = 5
  cSOURCE = 7
  cBYTES = 12
  cID = 3
  cOTHER = 14

  long_status: .byte 0

  .proc print_status
    lda long_status
    bne print_long_status
    jmp print_short_status
  .endproc
  
  .proc print_long_status
    jsr print_IP
    PrintChr ' '
    jsr print_depth
    PrintChr ' '
    jsr token_bytes
    jsr print_indent
    jsr token_source
    rts
  .endproc

  .proc print_short_status
    jsr print_IP
    PrintChr ' '
    jsr print_indent
    jsr print_indent
    jsr token_source
    rts
  .endproc

  .proc print_IP
    ColorSet cIP
    PrintChr '['
    IPrintHex IP
    PrintChr ']'
    rts
  .endproc

  .proc print_depth
    ColorSet cOTHER
    lda RP
    clc
    ror
    jsr print::print_hex_digits
    rts
  .endproc

  .proc print_indent
    ldx RP
    inx
    loop:
      PrintChr ' '
      dex
      dex
    bpl loop
    rts
  .endproc


  .proc token_bytes
    ColorSet cBYTES
    PeekX IP,1
    sta tmp+1
    jsr print::print_hex_digits
    
    PeekA IP
    sta tmp
    jsr print::print_hex_digits
    PeekX tmp,vocab::token_offset
    beq skip
    tay
    ldx #2
    loop:
      PrintChr ':'
      inx
      PeekX IP
      jsr print::print_hex_digits
      dex
      PeekX IP
      jsr print::print_hex_digits
      inx
      dey
      dey
    bne loop
    rts
    skip:
      PrintString "     "
    rts
    tmp:.word 2
  .endproc 

  .proc token_source
    ColorSet cSOURCE
    PeekA IP
    sta rewrite+1
    PeekA IP, 1
    sta rewrite+2
    IAddB rewrite+1, vocab::list_offset
    rewrite:
    jmp ($FEDA)
  .endproc


  skip_depth: .byte 0
  debug_state: .byte 0 ; -1 for quit, 0 for recognized command, 1 for ignored

  .proc do_debug
    CClear debug_state
    loop:
      BraTrue runtime::ended, exit
      lda debug_state
      bmi exit
      bne skip_status

      NewLineSoft
      ColorPush 5
      jsr debug::print_status
      ColorPop
      skip_status: 

      CSet $CC, 0
      wait: jsr GETIN
      beq wait
      inc $CC
      jsr do_cmd
    bra loop
    exit:
    rts
  .endproc

  .proc do_cmd
    ; suppy the command character in A
    ldx #$ff
    stx debug_state
    and #$7F
    IfEq #'Q'
      rts
    EndIf
    IfEq #'I'
      NewLineSoft
      jmp runtime::run_to_end
    EndIf

    inc debug_state 

    IfEq #13
      NewLineSoft
      jmp debug::step_over
    EndIf
    IfEq #'P'
      NewLineSoft
      jmp debug::step_into
    EndIf
    IfEq #'O'
      NewLineSoft
      jmp debug::step_out
    EndIf

    IfEq #'L'
      lda #$FF
      eor long_status
      sta long_status
      rts
    EndIf
    IfEq #'S'
      NewLineSoft
      ColorPush 1
      PrintChr 'S'
      jsr PRINT_STACK
      ColorPop
      NewLineSoft
      rts
    EndIf
    IfEq #'D'
      IMov print::arg, runtime::IP 
      jsr print::dump_hex
      NewLineSoft
      rts
    EndIf
    IfEq #'R'
      ISet print::arg, rstack::STACK
      jsr print::dump_hex
      NewLineSoft
      rts
    EndIf
    inc debug_state 
    rts
  .endproc

  .proc step_into
    BraTrue runtime::ended, break
    jsr runtime::exec
    CMov skip_depth, RP
    break:
    rts
  .endproc

  .proc step_over
    CMov skip_depth, RP
    loop:
      BraTrue runtime::ended, break
      jsr runtime::exec
      BraLt skip_depth, RP, loop
    break:
    rts
  .endproc

  .proc step_out
    CMov skip_depth, RP
    loop:
      BraTrue runtime::ended, break
      jsr runtime::exec
      lda RP
      cmp skip_depth
      bcc loop         ; current depth is larger than skip depth
      bne break        ; current depth is smaller than skip depth
      PeekA IP
      cmp bytecode::RET
      bne loop         ; it's not a RET token  
    break:
    rts
  .endproc

.endscope
