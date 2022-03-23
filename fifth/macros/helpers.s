
.macro Set8 arg1, arg2
  lda #arg2
  sta arg1
.endmacro

.macro Set16 arg1, arg2
  lda #<arg2
  sta arg1
  lda #>arg2
  sta arg1+1
.endmacro

.macro Mov8 arg1, arg2
  lda arg2
  sta arg1
.endmacro

.macro Mov16 arg1, arg2
  lda arg2
  sta arg1
  lda arg2+1
  sta arg1+1
.endmacro


.macro IfTrue arg1,arg2
  .ifnblank arg2
    lda arg1
    bne arg2
  .else
    bne arg1
  .endif
.endmacro

.macro IfFalse arg1,arg2
  .ifnblank arg2
    lda arg1
    bne arg2
  .else
    beq arg1
  .endif
.endmacro


.macro IfEq arg1,arg2,arg3
  .ifnblank arg3
    lda arg1
    cmp arg2
    beq arg3
  .else
    cmp arg1
    beq arg2
  .endif
.endmacro

.macro IfNe arg1,arg2,arg3
  .ifnblank arg3
    lda arg1
    cmp arg2
    bne arg3
  .else
    cmp arg1
    bne arg2
  .endif
.endmacro

.macro IfLt arg1,arg2,arg3
  .ifnblank arg3
    lda arg1
    cmp arg2
    bcc arg3
  .else
    cmp arg1
    bcc arg2
  .endif
.endmacro


.macro IfGe arg1,arg2,arg3
  .ifnblank arg3
    lda arg1
    cmp arg2
    bcs arg3
  .else
    cmp arg1
    bcs arg2
  .endif
.endmacro

