.scope here
  .proc load
    sta HERE
    sty HERE+1
    rts
  .endproc
  .proc get
    lda HERE
    sty HERE
    rts
  .endproc 

  .proc forward
    IInc HERE 
    rts
  .endproc

  .proc forward_a
    IAddA HERE
    rts
  .endproc

  .proc back_a
    ISubA HERE
    rts
  .endproc


  .proc back
    IDec HERE
    rts
  .endproc


  .proc peek
    ldx #0
    lda (HERE,x)
    rts 
  .endproc
  .proc read_byte
    ldx #0
    lda (HERE,x)
    jmp forward
  .endproc

  .proc poke
    ldx #0
    sta (HERE,x)
    rts 
  .endproc
  .proc write_byte
    ldx #0
    sta (HERE,x)
    jmp forward
  .endproc

  .proc read_word
    ldx #0
    lda (HERE,x)
    pha
    IInc HERE
    lda (HERE,x)
    tay
    pla
    rts
  .end 

  .proc write_word
    ldx #0
    lda (HERE,x)
    pha
    IInc HERE
    lda (HERE,x)
    tay
    pla
    rts
  .end 
    
  .proc deref
    jsr read_byte
    pha
    jsr here_read_a
    sta HERE+1
    pla 
    sta HERE 
    rts
  .endproc
