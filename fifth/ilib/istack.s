.scope istack

  STACK: .res 256
  STACK_END:
  SP: .byte STACK_END-STACK
  S0: .byte 0
  S1: .byte 0
  P0: .byte 0
  P1: .byte 0

  .proc pop
    stx rwx+1
    ldx SP
    inx
    lda STACK,x
    sta S0
    inx
    lda STACK,x
    sta S1
    stx SP
    rwx: ldx #0
    rts
  .endproc

  .proc push
    stx rwx+1
    ldx SP
    dex 
    lda S1
    sta STACK,x

    dex 
    lda S0 
    sta STACK,x
    stx SP
    rwx: ldx #AA
  .endproc

  ; passthrough
  .proc store 
    stx S0
    sty S1
    rts 
  .endscope

  .proc load 
    ldx S0
    ldy S1
    rts
  .endscope

  .proc inc
    inc S0
    bne skip
    inc S1
    skip:
    rts
  .endproc

  .proc dec 
    lda S0
    bne skip
    inc S1
    skip:
    inc S0
    rts
  .endproc

  .proc add
    jsr pop
  .endproc
  ; passthrough
  .proc _add
    clc
    txa
    adc S0
    sta S0
    tya   
    adc S1
    sta S1
    rts
  .endproc

  .proc get
    ldx S0
    ldy S1
    jsr xy::deref
    stx S0
    sty S1
    rts
  .endproc

  .proc set
    lda S0
    sta rw1+1

    lda S1
    sta rw0+2
    sta rw1+2

    txa
    rw0: sta $AA00,x
    tya
    ldy #1
    rw1: sta $AABB,y 
    tay
    rts  
  .endproc
