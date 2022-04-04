
.scope idump
  PP:$FD


  .proc idump
    
    loop:
      jsr dump_hex

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


  .proc dump_hex
    ClearScreen
    ldy #0
    ldx #0
    print_line:
      lda PP+1
      jsr print_hex_digits
      lda PP
      jsr print_hex_digits
      PrintChr ' '
      .scope print_bytes
        loop:
        tya
        and #1
        bne colon
          PrintChr ' '
          bra space
        colon:
          PrintChr ':'
        space:        
        PeekX PP
        jsr print_hex_digits
        IInc PP
        dey
        tya
        and #7
        bne loop
        break:
      .endscope
      ISubB PP, 8
      
      PrintChr ' '
      
      .scope print_chars
        loop:
          tya
          and #3
          bne skip
            PrintChr ' '
          skip: 
          PeekX PP
          jsr dump_char
          IInc PP
          dey
          tya
          and #7
          bne loop
        break:
    .endscope
    next_line:
    tya
    BraFalse exit
    jmp print_line
    exit:
      rts
  .endproc

  .proc new_line_soft
    ; prints a new line only if cursor column > 0
    ; used to avoid printing blank lines
    sec
    jsr $e50a
    tya
    IfTrue
      NewLine
    EndIf
    rts
  .endproc 
.endscope