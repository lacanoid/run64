
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
    jsr token_code
    ColorSet cID
    jsr token_id
    jsr token_payload
    PrintChr ' '
    jsr token_source
    rts
  .endproc

  .proc print_short_status
    jsr print_IP
    PrintChr ' '
    jsr print_indent
    jsr token_source
    rts
  .endproc

  .proc print_IP
    ColorSet cIP
    IPrintHex IP
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

  .proc token_code
    ColorSet cBYTES
    PeekA IP
    jmp print::print_hex_digits
  .endproc 

  .proc token_id
    ColorSet cID
    PeekA IP
    and #15
    tax
    lda table,x
    jmp CHROUT
    table:
      .asciiz "PRISWTFN????X???"
  .endproc 

  .proc token_bytes
    ColorSet cBYTES
    PeekA IP
    pha
    jsr print::print_hex_digits
    pla

    BraEq #bytecode::RET, no_payload
    BraEq #bytecode::NOP, no_payload

    PrintChr ':'
    PeekA IP,1
    sta print::arg
    jsr print::print_hex_digits
    PrintChr ':'
    PeekA IP,2
    sta print::arg+1
    jmp print::print_hex_digits
    no_payload:
      lda #' '
      jsr CHROUT
      jsr CHROUT
      jsr CHROUT
      jsr CHROUT
      jsr CHROUT
      jmp CHROUT
  .endproc 

  .proc token_payload
    ColorSet cBYTES
    PeekA IP
    and #15
    BraEq #bytecode::RET, no_payload
    BraEq #bytecode::NOP, no_payload

    PeekA IP,2
    sta print::arg
    jsr print::print_hex_digits
    PeekA IP,1
    jsr print::print_hex_digits
    rts

    no_payload:
      lda #' '
      jsr CHROUT
      jsr CHROUT
      jsr CHROUT
      jmp CHROUT
  .endproc 
  
  .proc token_source
    ColorSet cSOURCE
    ;jsr runtime::list_entry
    ;IPrintHex result
    PeekA IP
    BraEq #bytecode::RUN, ok
    BraEq #bytecode::CTL, ok
    rts
    ok:
    PeekA IP, 1 
    sta rewrite+1
    PeekA IP, 2
    sta rewrite+2
    IAddB rewrite+1, vocab::list_offset
    ;IPrintHex rewrite+1
    rewrite:
    jmp ($FEDA)

    PeekA IP
    ;and #15
    IfEq #bytecode::INT
      PeekA IP,1
      sta print::arg
      PeekA IP,2
      sta print::arg+1
      jsr print::print_dec
      rts
    EndIf
    IfEq #bytecode::STR
      PrintChr '"' 
      IMov print::arg, IP
      IAddB print::arg, 3
      jsr print::print_z
      PrintChr '"' 
      rts
    EndIf
    IfEq #bytecode::CTL
      PeekA IP,1
      sta print::arg
      PeekA IP,2
      sta print::arg+1
      IAddB print::arg, vocab::name_offset
      jsr print::print_z
      rts
    EndIf
    IfEq #bytecode::RUN
      PeekA IP,1
      sta print::arg
      PeekA IP,2
      sta print::arg+1
      IAddB print::arg, vocab::name_offset
      jsr print::print_z
      rts
    EndIf
    IfEq #bytecode::IF0
      PrintZ cIF, vocab::name_offset
      rts
    EndIf
    IfEq #bytecode::THN
      PrintZ cTHEN, vocab::name_offset
      rts
    EndIf
    IfEq #bytecode::BGN
      PrintZ cBEGIN, vocab::name_offset
      rts
    EndIf
    IfEq #bytecode::AGN
      PrintZ cAGAIN, vocab::name_offset
      rts
    EndIf
    IfEq #bytecode::WHL
      PrintZ cWHILE, vocab::name_offset
      rts
    EndIf
    IfEq #bytecode::ELS
      PrintZ cELSE, vocab::name_offset
      rts
    EndIf
    IfEq #bytecode::RET
      PrintChr 'R'
      PrintChr 'E'
      PrintChr 'T'
      rts
    EndIf

    rts
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
