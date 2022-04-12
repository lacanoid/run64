
.ifndef __XY_INCLUDED__
__XY_INCLUDED__ = 1

.macro ldxy arg
  .if (.match (.left (1, {arg}), #))
    ldx #<(.right (.tcount ({arg})-1, {arg}))
    ldy #>(.right (.tcount ({arg})-1, {arg}))
  .else
    ldx arg
    ldy arg+1
  .endif
.endmacro

.macro stxy arg
  stx arg
  sty arg+1
.endmacro

.macro ldpxy
  .local rw
  sty rw+2
  rw: lda $FA00,x
.endmacro


.macro stpxy
  .local rw
  sty rw+2
  rw: sta $FA00,x
.endmacro

.macro ldixy
  jsr xy::indexed
.endmacro
.macro phxy
  jsr xy::phxy
.endmacro
.macro plxy
  jsr xy::plxy
.endmacro


.macro inxy
  .local skip
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

.macro rdxy 
  jsr xy::read
.endmacro

.macro wrxy 
  jsr xy::write
.endmacro

.macro adxy arg
  .ifnblank arg
    pha
    lda arg
    jsr xy::add
    pla
  .else 
    jsr xy::add
  .endif
.endmacro

.macro adsxy arg
  .ifnblank arg
    pha
    lda arg
    jsr xy::adds
    pla
  .else 
    jsr xy::adds
  .endif
.endmacro

.macro sbxy arg
  .ifnblank arg
    pha
    lda arg
    jsr xy::sub
    pla
  .else 
    jsr xy::sub
  .endif
.endmacro

.macro goxy
  jsr xy::deref
.endmacro

.macro jsxy 
  jsr xy::jsxy
.endmacro

.macro jsixy 
  jsr xy::jsixy
.endmacro

.macro jpxy 
  jmp xy::jsxy
.endmacro

.macro jpixy 
  jmp xy::jsixy
.endmacro

.scope xy
  .pushseg
  .data 
    STACK_DEPTH = 16
    .align 2
    stack: .res STACK_DEPTH*2
    sp: .addr stack + STACK_DEPTH*2 - 2
  .popseg

  .proc phxy
    bit sp
    bne skip
      dec sp+1
    skip:
    dec sp
    dec sp
    
    stx sp
    sty sp+1
    rts 
  .endproc

  .proc plxy

    ldx sp
    ldy sp+1

    inc sp
    inc sp
    bne skip
      inc sp+1
    skip:

    rts 
  .endproc

  .proc jsxy
    stxy rw+1
    rw: jmp $FADE
  .endproc

  .proc jsixy
    stxy rw+1
    rw: jmp ($FADE)
  .endproc


  .proc deref
    pha
    sty lo+2
    sty hi+2
    stx hi+1

    lo: lda $AA00,x
    tax
    ldy #1
    hi: lda $AABB,y 
    tay
    pla
    rts  
  .endproc

  .proc read
    ldpxy
    inxy
    rts
  .endproc 

  .proc write
    stpxy
    inxy
    rts
  .endproc 

  .proc pop
    dexy
    ldpxy
    rts
  .endproc 

  .proc indexed
    PushX
    PushY
      adxy
      ldpxy
    PopY
    PopX
    rts
  .endproc 

  .proc adds 
    pha
    stx rwx+1
    sty rwy+1
    clc
    rwx: adc #00
    tax 
    pla
    pha
    bmi minus
    lda #00
    .byte $2c
    minus: lda #$ff
    rwy: adc #00
    tay
    pla
    rts
  .endproc

  .proc add
    pha
    stx rw+1
    clc
    rw: adc #00
    tax 
    bcc skip 
      iny
    skip:
    pla
    rts
  .endproc

  .proc sub
    pha
    stx rw+1
    sec
    rw: adc #00
    tax
    bcs skip 
      dey
    skip:
    pla
    rts
  .endproc
.endscope 
.endif