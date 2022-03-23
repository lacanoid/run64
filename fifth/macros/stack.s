
.macro SpLoad
  ldx f_SP
.endmacro

.macro SpInc
  inx
  inx
  stx f_SP
.endmacro

.macro SpDec
  dex
  dex
  stx f_SP
.endmacro

.macro GetLo d
  lda STACK-d*2,x
.endmacro

.macro GetHi d
  lda STACK-d*2+1,x
.endmacro

.macro Insert d, arg
  lda #<arg
  sta STACK-d*2,x
  lda #>arg
  sta STACK-d*2+1,x
.endmacro

.macro InsertA d
  sta STACK-d*2,x
  lda #0
  sta STACK-d*2+1,x
.endmacro

.macro InsertFrom d, address
  lda address
  sta STACK-d*2,x
  lda address+1
  sta STACK-d*2+1,x
.endmacro

.macro InsertByteFrom d, address
  lda address
  InsertA d
.endmacro

.macro Copy c, d
  lda STACK-c*2,x
  sta STACK-d*2,x
  lda STACK-c*2+1,x
  sta STACK-d*2+1,x
.endmacro

.macro CopyTo c, address
  lda STACK-c*2,x
  sta address
  lda STACK-c*2+1,x
  sta address+1
.endmacro

.macro CopyByteTo c, address
  lda STACK-c*2,x
  sta address
.endmacro

.macro Push arg
  Insert 0, arg
  SpInc 
.endmacro

.macro PushA
  InsertA 0
  SpInc 
.endmacro

.macro PushFrom address
  InsertFrom 0, address
  SpInc 
.endmacro

.macro PushByteFrom address
  InsertByteFrom 0, address
  SpInc 
.endmacro

.macro PrintDec
  jsr print_dec
.endmacro

