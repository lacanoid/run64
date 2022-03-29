.macro bra arg
  clv 
  bvc arg
.endmacro

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
  lda #<(arg2)
  sta arg1
  lda #>(arg2)
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


