.ifndef ::__PRINT_INCLUDED__
::__PRINT_INCLUDED__ = 1

.include "defs/defs-auto.inc"
.include "macros/basics.inc"

.macro print fn
  .if (.match (.left (1, {fn}), {""}))
    prints fn
  .else
    jsr print::fn
  .endif
.endmacro

.macro prints arg
  .local string
  .pushseg 
  .data
    string:
    .byte arg, 0
  .popseg
  ldx #<string
  ldy #>string
  jsr print::z_at_xy
.endmacro

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
    jmp _char
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
  .endproc
  ; passthrough
  .proc _char
    ora CHAR_OR
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
    spaces: 
      lda #' '
      jsr _char
    bcc spaces
    rts
  .endproc
  .proc spaces_to
    eor #$FF
    sec
    adc #40
    tay 
    spaces: 
      lda #' '
      jsr _char
      cpy COLUMN
    bne spaces
    rts
  .endproc
  .proc clear_rest
    spaces: 
      lda #' '
      jsr _char
    bcc spaces
    bne spaces
    rts
  .endproc

  .proc number_a
    sta arg
    lda #0
    sta arg+1
    jmp number
  .endproc
  
  .proc number_xy
    stx arg
    sty arg+1
  .endproc
  ;passthrough
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

  .proc z_at_xy
    stx read+1
    sty read+2
    ;jsr word_xy
    loop:
      read: lda $FADE
      beq exit
      IInc read+1
      jsr char
      bra loop
    exit:
      rts
  .endproc

  .proc z_at_xy_plus_a
    stx x2a +1
    sty y2a+1
    clc
    x2a: adc #00
    sta read+1
    y2a: lda #00
    adc #0
    sta read+2
    loop:
      read: lda $FADE
      beq exit
      IInc read+1
      jsr char
      bra loop
    exit:
      rts
  .endproc

  .proc len_at_xy
    stx read+1
    sty read+2
    tax 
    loop:
      read: lda $FADE
      dex
      beq exit
      jsr char
      IInc read+1
      bra loop
    exit:
      rts
  .endproc


  .proc byte_a
    pha
    lsr 
    lsr 
    lsr 
    lsr
    jsr nybble_a
    pla
  .endproc

  .proc nybble_a
    and #$0f
    cmp #10
    bcc skip
    adc #6
    skip:
    add #'0'
    jmp char
  .endproc

  .proc word_xy
    stx rw+1
    tya
    jsr byte_a
    rw: lda #$ff
    jmp byte_a
  .endproc
.endscope
.endif