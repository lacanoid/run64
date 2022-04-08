.scope xy
  .proc peek
    stx rwa+1
    sty rwa+2
    rwa: lda $FADE
    rts
  .endproc 

  .proc poke
    stx rwa+1
    sty rwa+2
    rwa: sta $FADE
    rts
  .endproc 
  .proc read
    stx rwa+1
    sty rwa+2
    rwa: lda $FADE
  .endproc
  .proc inc
    inx
    bne skip
    iny
    skip:
    rts
  .endproc 
  .proc dec
    cpx #0
    bne skip
      dey
    skip:
    dex
    rts
  .endproc 
  .proc deref
    jsr read
    pha
    jsr read
    tay
    pla
    tax
    rts
  .endproc
.endproc

.macro ldxy 
.endmacro 

.macro stxy 
.endmacro 

.macro inxy
.endmacro 

.macro dexy
.endmacro 

.macro inxy
.endmacro 

.macro adxy
.endmacro

.macro sbxy
.endmacro

.macro pkxy

.macro pkxy