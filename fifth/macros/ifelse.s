
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

.macro Again
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

