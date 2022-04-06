
.scope debug
  ::LP = IP

  cIP = 5
  cSOURCE = 7
  cBYTES = 12
  cID = 3
  cOTHER = 14

  long_listing: .byte 0

  ::print_status:
  .proc print_status
    rts
    sec
    jsr PLOT
    stx tx
    sty ty
    ldx #0
    ldy #0
    clc
    jsr PLOT
    jsr print_IP
    ldx tx
    ldy ty
    clc
    jsr PLOT
    PrintChr '!'
    rts
    tx: .byte 0
    ty: .byte 0
  .endproc

  .proc print_listing
    lda long_listing
    bne print_long_listing
    jmp print_short_listing
  .endproc
  
  .proc print_long_listing
    jsr print_IP
    PrintChr ' '
    jsr print_depth
    PrintChr ' '
    jsr token_bytes
    jsr print_indent
    jsr token_source
    rts
  .endproc

  .proc print_short_listing
    jsr print_IP
    PrintChr ' '
    jsr print_indent
    jsr print_indent
    jsr token_source
    rts
  .endproc

  ::print_IP:
  .proc print_IP
    ColorSet cIP
    PrintChr '['
    IPrintHex IP
    PrintChr ']'
    rts
  .endproc

  ::print_depth:
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
    PeekX tmp,vocab::flags_offset
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
    rts
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
      bne skip_listing

      NewLineSoft
      ColorPush 5
      jsr debug::print_listing
      ColorPop
      skip_listing: 

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
      jmp debug::run_step_over
    EndIf
    IfEq #'P'
      NewLineSoft
      jmp debug::run_step_into
    EndIf
    IfEq #'O'
      NewLineSoft
      jmp debug::run_step_out
    EndIf

    IfEq #'L'
      lda #$FF
      eor long_listing
      sta long_listing
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
      IMov print::arg, IP 
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
  
  ::run_step_into:
  .proc run_step_into
    BraTrue runtime::ended, break
    jsr runtime::exec
    CMov skip_depth, RP
    break:
    rts
  .endproc

  ::run_step_over:
  .proc run_step_over
    ;jsr print_IP
    ;CMov skip_depth, RP
    jsr print_depth
    jsr print_IP
    loop:
      BraTrue runtime::ended, break
      jsr runtime::exec
      BraLt skip_depth, RP, loop
    break:
    NewLine
    rts
  .endproc
  
  ::run_step_out:
  .proc run_step_out
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

  .proc idump
    loop:
      jsr print::dump_hex

      CSet $CC, 0
      wait: 
        jsr GETIN
      beq wait
      
      and #$7F

      BraEq #13,exit
      IfEq #'W'
        dec print::arg+1
        bra next
      EndIf
      IfEq #'S'
        inc print::arg+1
        bra next
      EndIf
      IfEq #'A'
        ISubB print::arg,1
        bra next
      EndIf
      IfEq #'D'
        IAddB print::arg,1
        bra next
      EndIf
      bra wait
    next:
      ldx #16
    go_up:
      PrintChr $91
      dex
      bne go_up
      bra loop
    exit:
      CSet $CC, 1
    rts
  .endproc
.endscope
