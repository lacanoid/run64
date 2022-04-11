.scope xy

  .macro ldd arg
    .if (.match (.left (1, {arg}), #))
      ldx #<arg
      ldy #>arg
    .else 
      ldx arg
      ldy arg+1
    .endif
  .endmacro

    
  .macro lddi arg
    .ifnblank arg
      ldd arg
    .endif

    .local rw
    sty rw+2
    rw: lda $FA00,x
  .endproc 

  .macro std arg
    sta arg
    stx arg+1
  .endmacro

  
  .macro stdi arg 
    .ifnblank arg
      ldd arg
    .endif
    .local rw
    sty rw+2
    rw: sta $FA00,x
  .endmacro
  
  .macro ind
    inx
    bne skip
    iny
    skip:
  .endmacro
  
  .macro ded
    cpx #0
    bne skip
      dey
    skip:
    dex
    rts
  .endmacro

  .macro rdd arg
    .ifnblank arg
      ldd arg
    .endif
    lddi
    ind
  .macro

  .endproc
  .proc deref
    sty lo+2
    stx hi+1
    sty hi+2

    lo: lda $AA00,x
    tay
    ldy #1
    hi: lda $AABB,y 
    tay
    rts  
  .endproc
      
  .endproc
.endproc
 

.macro stxy 
  stx arg
  sty arg+1
.endmacro 

.macro inxy
  inx
  bne skip
  iny
  skip:
.endmacro 

.macro dexy
  cpx #0
  bne skip
  dey
  skip:
  dex 
.endmacro 

.macro adxy arg
  .if .blank ({arg}) 
    clc
    stx rwa+1
    rwa: adc #$ff
    tax
    bcc skip
    iny
  .else
    clc 
    txa
    adc arg 
    tax
    bcc skip
    iny
  .endif
.endmacro

.macro addxy
  .if (.match (.left (1, {arg}), #))
    clc
    stx rwx+1
    sty rwy+1
    txa
    rwx: adc #<(.right (.tcount ({arg})-1, {arg}))
    tax
    tya
    rwy: adc #>(.right (.tcount ({arg})-1, {arg}))
    tay 
  .else
    clc
    stx rwx+1
    sty rwy+1
    txa
    rwx: adc arg 
    tax
    tya
    rwy: adc arg+1
    tay 

  .endif

  .macro in2xy
    inc x
    bne skip1
    inc y
    skip1:
    inc x
    bne skip2
    inc y
    

.endmacro