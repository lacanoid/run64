.scope print
  .data
    PP = $D1
    CP = $F3
    COLUMNS = 40
    COLUMN: .byte 0
    CHAR_OR: .byte 0
    arg: .word 0
  .code

  .proc rev_on
    pha
    lda #$80
    sta CHAR_OR
    pla
    rts
  .endproc
  
  .proc rev_off
    pha
    lda #$00
    sta CHAR_OR
    pla
    rts
  .endproc

  .proc reset
    ISet CP, COLORAM
    ISet PP, VICSCN
    CSet COLUMN,COLUMNS
    rts
  .endproc

  .proc space
    lda #' '
    ldx #0
    sta (PP,x)
    jmp _advance
  .endproc

  .proc char
    sta rewrite+1
    and #$E0
    beq c80       ; $0 -> $80

    cmp #$40       
    beq c40      ; $40 -> $40

    cmp #$20       
    beq c00       ; $20 -> $00

    cmp #$A0
    bcc cC0       ; $60 & $80 -> $C0
    beq c40       ; $A0 -> $40
    
    cmp #$C0
    bne c00       ; $E0 -> $00
    ;pass through ; $C0 -> $80
    c80:
      lda #$80
      bne done
    cC0:
      lda #$40
      bne done
    c00:
      lda #$00
      bra done
    c40:
      lda #$C0
    done: 
    clc
    rewrite:
    adc #$ff 
    ora CHAR_OR
  .endproc
  ; passthrough
  .proc _char
    ldx #0
    sta (PP,x)
    lda COLOR
    sta (CP,X)
  .endproc
  ; passthrough
  .proc _advance
    inc CP
    inc PP
    bne skip
      inc CP+1
      inc PP+1
      lda PP+1
      cmp #>(VICSCN+1024)
      bne skip
      jsr reset
      lda #0  
      sec
      rts ; +z, +c
    skip:
    dec COLUMN
    beq nl
      clc 
      rts ; -z, -c
    nl: 
      CSet COLUMN,COLUMNS
      sec
      rts 
  .endproc

  .proc nl
    pha
    lda COLUMN
    beq exit
    
    lda #' '
    ora CHAR_OR
    sta rewrite+1
    lda COLOR
    sta color+1
    loop: 
      ldx #0
      rewrite:
      lda #' '
      sta (PP,x)
      color: 
      lda #$FF
      sta (CP,x)
      jsr _advance
    bcc loop
    exit:
    pla
    rts
  .endproc
  .proc clear_rest
    pha
    lda COLUMN
    beq exit
    
    lda #' '
    sta rewrite+1
    loop: 
      ldx #0
      rewrite:
      lda #' '
      sta (PP,x)
      jsr _advance
    bne loop
    exit:
    pla
    rts
  .endproc


  .proc number
    ; print a 16 bit unsigned binary integer from stack in base 10
    ; leading zeros are omitted
    ; expects a pp to stack element in x

    print_uint16:
      lda      #0                  ; terminator for digits on stack
    print_uint16_1:
      pha                         ; push terminator or digit onto stack
      lda     #0                  ; accumulator for division
      clv                         ; v flag will be set if any quotient bit is 1
      ldy     #16                 ; number of input bits to process
    print_uint16_2:
      cmp     #5                  ; is accumulator >= 5 ?
      bcc     print_uint16_3
      sbc     #$85                ; if so, subtract 5, toggle bit 7 and set v flag (unwanted bit 7 will be shifted out imminently)
      sec                         ; set c (=next quotient bit)
    print_uint16_3:
      rol     arg              ; shift quotient bit into x while shifting out next dividend bit into a
      rol     arg+1
      rol                         ; shift dividend into a
      dey
      bne     print_uint16_2     ; loop until all original dividend bits processed
      ora     #$30                ; a contains remainder from division by 10 - convert to ascii digit
      bvs     print_uint16_1     ; if quotient was not zero, loop back to push digit on stack then divide by 10 again
  print_uint16_4:
      pha
      jsr char
      pla
      pla                         ; retrieve next digit from stack (or zero terminator)
      bne     print_uint16_4     ; if not terminator, print digit
      rts
  .endproc

.endscope

