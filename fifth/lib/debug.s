.scope debug
  IP = runtime::IP

  .proc print_IP
    IPrintHex IP
    rts
  .endproc

  .proc token_code
    Peek IP
    jmp print::print_hex_digits
  .endproc 


  .proc token_id
    Peek IP
    and #15
    tax
    lda table,x
    jmp CHROUT
    table:
      .asciiz "PRISWTFN????X???"
  .endproc 

  .proc token_bytes
    Peek IP
    jsr print::print_hex_digits
    Peek IP

    BraEq #bytecode::tRET, no_payload
    BraEq #bytecode::tNOP, no_payload

    PrintChr ':'
    Peek IP,1
    sta print::arg
    jsr print::print_hex_digits
    PrintChr ':'
    Peek IP,2
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
    Peek IP
    and #15
    BraEq #bytecode::tRET, no_payload
    BraEq #bytecode::tNOP, no_payload

    Peek IP,2
    sta print::arg
    jsr print::print_hex_digits
    Peek IP,1
    jsr print::print_hex_digits
    rts

    no_payload:
      lda #' '
      jsr CHROUT
      jsr CHROUT
      jsr CHROUT
      jmp CHROUT
  .endproc 


  .proc describe_token
    ColorPush 12
    jsr token_code
    ColorSet 3
    jsr token_id
    ColorSet 12
    jsr token_payload
    PrintChr ' '
    ColorSet 7
    jsr token_source
    PrintChr 8
    ColorPop
    rts
  .endproc

  .proc token_source
    Peek IP
    ;and #15
    IfEq #bytecode::tINT
      Peek IP,1
      sta print::arg
      Peek IP,2
      sta print::arg+1
      jsr print::print_dec
      rts
    EndIf
    IfEq #bytecode::tSTR
      PrintChr '"' 
      IMov print::arg, IP
      IAddB print::arg, 3
      jsr print::print_z
      PrintChr '"' 
      rts
    EndIf
    IfEq #bytecode::tRUN
      Peek IP,1
      sta print::arg
      Peek IP,2
      sta print::arg+1
      IAddB print::arg, vocab::name_offset
      jsr print::print_z
      rts
    EndIf
    IfEq #bytecode::tIF
      PrintZ cIF, vocab::name_offset
      rts
    EndIf
    IfEq #bytecode::tTHEN
      PrintZ cTHEN, vocab::name_offset
      rts
    EndIf
    IfEq #bytecode::tBEGIN
      PrintZ cBEGIN, vocab::name_offset
      rts
    EndIf
    IfEq #bytecode::tAGAIN
      PrintZ cAGAIN, vocab::name_offset
      rts
    EndIf
    IfEq #bytecode::tWHILE
      PrintZ cWHILE, vocab::name_offset
      rts
    EndIf
    IfEq #bytecode::tELSE
      PrintZ cELSE, vocab::name_offset
      rts
    EndIf
    IfEq #bytecode::tRET
      PrintChr 'R'
      PrintChr 'E'
      PrintChr 'T'
      rts
    EndIf

    rts
  .endproc
.endscope
