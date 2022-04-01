.scope print
  PP: .word 0
  arg: .word 0
  .proc print_dec 
      ; Print a 16 bit unsigned binary integer from stack in base 10
      ; Leading zeros are omitted
      ; expects a PP to stack element in x

      PRINT_UINT16:
        LDA      #0                  ; terminator for digits on stack
      PRINT_UINT16_1:
        PHA                         ; push terminator or digit onto stack
        LDA     #0                  ; accumulator for division
        CLV                         ; V flag will be set if any quotient bit is 1
        LDY     #16                 ; number of input bits to process
      PRINT_UINT16_2:
        CMP     #5                  ; is accumulator >= 5 ?
        BCC     PRINT_UINT16_3
        SBC     #$85                ; if so, subtract 5, toggle bit 7 and set V flag (unwanted bit 7 will be shifted out imminently)
        SEC                         ; set C (=next quotient bit)
      PRINT_UINT16_3:
        ROL     arg              ; shift quotient bit into X while shifting out next dividend bit into A
        ROL     arg+1
        ROL                         ; shift dividend into A
        DEY
        BNE     PRINT_UINT16_2     ; loop until all original dividend bits processed
        ORA     #$30                ; A contains remainder from division by 10 - convert to ASCII digit
        BVS     PRINT_UINT16_1     ; if quotient was not zero, loop back to push digit on stack then divide by 10 again
    PRINT_UINT16_4:
        PHA
        JSR CHROUT
        PLA
        PLA                         ; retrieve next digit from stack (or zero terminator)
        BNE     PRINT_UINT16_4     ; if not terminator, print digit
        RTS
  .endproc

  .proc print_hex
    PrintChr '$'
    lda arg+1
    jsr print_hex_digits
    lda arg
    jsr print_hex_digits
    rts 
  .endproc

  .proc print_hex_digit
    BraGe #10, big
      add #'0'
      jsr CHROUT
      rts
    big:
      add #'A'-10
      jsr CHROUT
      rts
  .endproc

  .proc print_hex_digits
    pha
    sec
    lsr 
    lsr 
    lsr 
    lsr
    jsr print_hex_digit

    pla
    and #$0f
    jsr print_hex_digit 
    rts
  .endproc

  .proc print_z
    IMov PP, arg
    loop:
      PeekA PP
      BraFalse exit
      jsr CHROUT
      IInc PP
      bra loop
    exit:
      rts
  .endproc
  
  .proc dump_char
    pha
    and #$7f
    BraGe #32, regular_char
      PrintChr $12
      pla
      ora #$40
      jsr CHROUT
      ;PrintChr '.'
      PrintChr $92
      rts
    regular_char:
    pla ; pha from before
    jsr CHROUT
    CClear QTSW
    rts
  .endproc 

  .proc dump_text
    IMov PP, arg
    ldy #0
    ldx #0
    print_line:
      NewLine
      lda PP+1
      jsr print_hex_digits
      lda PP
      jsr print_hex_digits
      PrintChr ' '
      PrintChr ' '
      .scope print_chars
        loop:
          PeekA PP
          jsr dump_char
          IInc PP
          dey
          tya
          and #31
          bne loop
        break:
    .endscope
    next_line:
    tya
    BraTrue print_line
    exit:
      NewLine
      rts
  .endproc

  .proc dump_hex
    IMov PP, arg
    ldy #0
    ldx #0
    print_line:
      ;NewLine
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
