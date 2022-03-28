.macro sub arg1
  sec
  sbc arg1
.endmacro

.macro add arg1
  clc
  adc arg1
.endmacro

.macro CClear arg1
  lda #0
  sta arg1
.endmacro

.macro CxClear arg1, argx
  ldx argx
  lda #0
  sta arg1, x
.endmacro

.macro IClear arg1
  lda #0
  sta arg1
  sta arg1+1
.endmacro

.macro IxClear arg1, argx
  ldx argx
  lda #0
  sta arg1, x
  sta arg1+1, x
.endmacro

.macro CSet arg1, arg2
  lda #arg2
  sta arg1
.endmacro

.macro CxSet arg1, argx, arg2
  ldx argx
  lda #arg2
  sta arg1,x
.endmacro

.macro ISet arg1, arg2
  lda #<arg2
  sta arg1
  lda #>arg2
  sta arg1+1
.endmacro

.macro IxSet arg1, argx, arg2
  ldx argx
  lda #<arg2
  sta arg1,x
  lda #>arg2
  sta arg1+1,x
.endmacro

.macro CMov arg1, arg2
  lda arg2
  sta arg1
.endmacro

.macro CxMov arg1, argx, arg2
  ldx argx
  lda arg2
  sta arg1,x
.endmacro

.macro CMovCx arg1, arg2, argx
  ldx argx
  lda arg2,x
  sta arg1
.endmacro

.macro IMov arg1, arg2
  lda arg2
  sta arg1
  lda arg2+1
  sta arg1+1
.endmacro

.macro IxMov arg1, argx, arg2
  ldx argx
  lda arg2
  sta arg1,x
  lda arg2+1
  sta arg1+1,x
.endmacro

.macro IMovIx arg1, arg2, argx
  ldx argx
  lda arg2,x
  sta arg1
  lda arg2+1,x
  sta arg1+1
.endmacro


.macro BraTrue arg1,arg2
  .ifnblank arg2
    lda arg1
    bne arg2
  .else
    bne arg1
  .endif
.endmacro

.macro BraFalse arg1,arg2
  .ifnblank arg2
    lda arg1
    beq arg2
  .else
    beq arg1
  .endif
.endmacro


.macro BraEq arg1,arg2,arg3
  .ifnblank arg3
    lda arg1
    cmp arg2
    beq arg3
  .else
    cmp arg1
    beq arg2
  .endif
.endmacro

.macro JmpEq arg1,arg2,arg3
  .scope
    .ifnblank arg3
      lda arg1
      cmp arg2
      bne skip
        jmp arg3
      skip:
    .else
      cmp arg1
      bne skip
        jmp arg2
      skip:
    .endif
  .endScope
.endmacro


.macro BraNe arg1,arg2,arg3
  .ifnblank arg3
    lda arg1
    cmp arg2
    bne arg3
  .else
    cmp arg1
    bne arg2
  .endif
.endmacro

.macro BraLt arg1,arg2,arg3
  .ifnblank arg3
    lda arg1
    cmp arg2
    bcc arg3
  .else
    cmp arg1
    bcc arg2
  .endif
.endmacro


.macro BraGe arg1,arg2,arg3
  .ifnblank arg3
    lda arg1
    cmp arg2
    bcs arg3
  .else
    cmp arg1
    bcs arg2
  .endif
.endmacro

.macro BraNeg arg1,arg2
  .ifnblank arg2
    lda arg1
    bmi arg2
  .else
    bmi arg1
  .endif
.endmacro


.macro CShiftLeft arg1
  asl arg1 
.endmacro

.macro IShiftLeft arg1
  asl arg1
  rol arg1+1
.endmacro

.macro IAdd arg1, arg2
  clc
  lda arg1
  adc arg2
  sta arg1
  lda arg1+1
  adc arg2+1
  sta arg1+1
.endmacro

.macro IAddA arg1
  .scope
    add arg1
    sta arg1
    bcc skip
    
      inc arg1+1
    skip:
  .endscope
.endmacro

.macro ISubA arg1
  .scope
    eor #FF
    add #1
    add arg1
    sta arg1
    bcs skip
      dec arg1+1
    skip:
  .endscope
.endmacro

.macro ISubB arg1,arg2
  .scope
    lda arg1
    sub #arg2
    sta arg1
    bcs skip
      dec arg1+1
    skip:
  .endscope
.endmacro


.macro IAddB arg1,arg2
  .local skip
  lda arg1
  add #arg2
  bcc skip
  inc arg1+1
  skip:
  sta arg1
.endmacro

.macro IInc arg1
  .local skip
  inc arg1
  BraTrue skip
  inc arg1+1
  skip:
.endmacro


.macro Else arg1,arg2,arg3
  clc
  bcc _endif_
  _else_:
.endmacro
.macro EndIf
  .ifndef _else_
    _else_:
  .endif
  _endif_:
  .endScope
.endmacro

.macro Begin
  .scope
    continue:
.endmacro

.macro Break arg1,arg2,arg3
  jmp break
.endmacro

.macro Continue arg1,arg2,arg3
  jmp continue
.endmacro

.macro Repeat
  jmp continue
  break:
  .endScope
.endmacro

.macro IfGen1 id, cond
  .macro .ident(.concat("If",id)) arg1
    .scope 
      .ifblank arg1
        .ident(.concat("Bra",cond)) _else_
      .else 
        .ident(.concat("Bra",cond)) arg1,_else_
      .endif
.endmacro

.macro IfGen2 id, cond
  .macro .ident(.concat("If",id)) arg1,arg2
    .scope 
      .ifblank arg2
        .ident(.concat("Bra",cond)) arg1,_else_
      .else 
        .ident(.concat("Bra",cond)) arg1,arg2,_else_
      .endif
.endmacro

IfGen2 "Lt", "Ge"
.endmacro

IfGen2 "Ge", "Lt"
.endmacro

IfGen2 "Eq", "Ne"
.endmacro

IfGen2 "Ne", "Eq"
.endmacro

IfGen1 "True", "False"
.endmacro

IfGen1 "False", "True"
.endmacro
