.ifndef ::__IFELSE_INCLUDED__
::__IFELSE_INCLUDED__ = 1

; BraXX [arg,] <label>
  .macro _Branch inst, arg1, arg2
    .ifnblank arg2
      lda arg1
      inst arg2
    .else
      inst arg1
    .endif
  .endmacro

  .macro BraTrue arg1, arg2
    _Branch bne, arg1, arg2
  .endmacro

  .macro BraFalse arg1,arg2
    _Branch beq, arg1, arg2
  .endmacro

  .macro BraPos arg1,arg2
    _Branch bmi, arg1, arg2
  .endmacro

  .macro BraNeg arg1,arg2
    _Branch bpl, arg1, arg2
  .endmacro

;
; BraXX [arg,] <compareTo>, <label>

  .macro _BranchCompare inst, arg1, arg2, arg3
    .ifnblank arg3
      lda arg1
      cmp arg2
      inst arg3
    .else
      cmp arg1
      inst arg2
    .endif
  .endmacro

  .macro BraEq arg1,arg2,arg3
    _BranchCompare beq, arg1, arg2, arg3
  .endmacro

  .macro BraNe arg1,arg2,arg3
    _BranchCompare bne, arg1, arg2, arg3
  .endmacro

  .macro BraGe arg1,arg2,arg3
    _BranchCompare bcs, arg1, arg2, arg3
  .endmacro

  .macro BraLt arg1,arg2,arg3
    _BranchCompare bcc, arg1, arg2, arg3
  .endmacro

; JmpXX [arg,] <label>
  .macro _JmpUnless inst, arg1, arg2
    .local skip
    .ifnblank arg2
      lda arg1
      inst skip
      jmp arg2
    .else
      inst skip
      jmp arg1
    .endif
    skip:
  .endmacro

  .macro JmpTrue arg1, arg2
    _JmpUnless beq, arg1, arg2
  .endmacro
  
  .macro JmpFalse arg1, arg2
    _JmpUnless bne, arg1, arg2
  .endmacro

  .macro JmpPos arg1, arg2
    _JmpUnless bmi, arg1, arg2
  .endmacro
  
  .macro JmpNeg arg1, arg2
    _JmpUnless bpl, arg1, arg2
  .endmacro
  

;
; JmpXX [arg,] <compareTo>, <label>

  .macro _JmpUnlessCompare inst, arg1, arg2, arg3
    .local skip
    .ifnblank arg3
      lda arg1
      cmp arg2
      inst skip
      jmp arg3
    .else
      cmp arg1
      inst skip
      jmp arg2
    .endif
    skip:
  .endmacro

  .macro JmpEq arg1,arg2,arg3
    _JmpUnlessCompare bne, arg1, arg2, arg3
  .endmacro

  .macro JmpNe arg1,arg2,arg3
    _JmpUnlessCompare beq, arg1, arg2, arg3
  .endmacro

  .macro JmpGe arg1,arg2,arg3
    _JmpUnlessCompare bcc, arg1, arg2, arg3
  .endmacro

  .macro JmpLt arg1,arg2,arg3
    _JmpUnlessCompare bcs, arg1, arg2, arg3
  .endmacro

  .macro JmpCC arg1
    .local skip
    bcs skip
    jmp arg1
    skip:
  .endmacro

  .macro JmpCS arg1
    .local skip
    bcc skip
    jmp arg1
    skip:
  .endmacro
;
; IfXX [arg]
  .macro _Unless inst, arg1
    .scope 
      .ifnblank arg1
        _Branch inst,arg1,_else_
      .else 
        _Branch inst,_else_
      .endif
  .endmacro

  .macro IfTrue arg1
    _Unless beq, arg1
  .endmacro
  .macro IfFalse arg1
    _Unless bne, arg1
  .endmacro
  .macro IfPos arg1
    _Unless bmi, arg1
  .endmacro
  .macro IfNeg arg1
    _Unless bpl, arg1
  .endmacro
  .macro IfCarry
    .scope 
      bcs _else_
  .endmacro
  .macro IfNoCarry inst, arg1
    .scope
      bcc _else_
  .endmacro
  
;
; IfXX [arg,] <compareTo>
  .macro _UnlessCompare inst, arg1, arg2
    .scope 
      .ifnblank arg2
        _BranchCompare inst,arg1,arg2,_else_
      .else 
        _BranchCompare inst,arg1,_else_
      .endif
  .endmacro

  .macro IfEq arg1, arg2 
    _UnlessCompare bne, arg1, arg2
  .endmacro
  .macro IfNe arg1, arg2 
    _UnlessCompare beq, arg1, arg2
  .endmacro
  .macro IfGe arg1, arg2 
    _UnlessCompare bcc, arg1, arg2
  .endmacro
  .macro IfLt arg1, arg2 
    _UnlessCompare bcs, arg1, arg2
  .endmacro
;
; Else & EndIf
  .macro Else 
    clv
    bvc _endif_
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
.endif