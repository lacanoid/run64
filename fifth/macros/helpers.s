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

.macro IfNeg arg1,arg2
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
  sta arg1
  bcc skip
  inc arg1+1
  skip:
.endmacro

.macro IInc arg1
  .local skip
  inc arg1
  IfTrue skip
  inc arg1+1
  skip:
.endmacro
