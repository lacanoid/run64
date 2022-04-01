.macro SpInc
 ; PrintChr '+'
  inc f_SP
  inc f_SP
.endmacro

.macro SpDec
  ; PrintChr '-'
  dec f_SP
  dec f_SP
.endmacro

.macro GetLo d
  ldx f_SP
  lda STACK-d*2,x 
.endmacro

.macro GetHi d
  ldx f_SP
  lda STACK-d*2+1,x
.endmacro

.macro SetLo d
  ldx f_SP
  sta STACK-d*2,x
.endmacro

.macro SetHi d
  ldx f_SP
  sta STACK-d*2+1,x
.endmacro

.macro CmpLo d
  ldx f_SP
  cmp STACK-d*2,x
.endmacro

.macro CmpHi d
  ldx f_SP
  cmp STACK-d*2+1,x
.endmacro


.macro IsTrue d
  ldx f_SP
  lda STACK-d*2,x
  ora STACK-d*2+1,x
.endmacro

.macro Insert d, arg
  ldx f_SP
  lda #<arg
  sta STACK-d*2,x
  lda #>arg
  sta STACK-d*2+1,x
.endmacro

.macro InsertA d
  ldx f_SP
  sta STACK-d*2,x
  lda #0
  sta STACK-d*2+1,x
.endmacro

.macro InsertFrom d, address
  ldx f_SP
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
  ldx f_SP
  lda STACK-c*2,x
  sta STACK-d*2,x
  lda STACK-c*2+1,x
  sta STACK-d*2+1,x
.endmacro

.macro CopyTo c, address
  ldx f_SP
  lda STACK-c*2,x
  sta address
  lda STACK-c*2+1,x
  sta address+1
.endmacro

.macro CopyByteTo c, address
  ldx f_SP
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

.macro PopA
  GetLo 1
  SpDec
.endmacro

.macro PopTo arg
  CopyTo 1, arg
  SpDec 
.endmacro

.macro OutputDec
  CopyTo 1, print::arg
  jsr print::print_dec
.endmacro

.macro OutputHex
  CopyTo 1, print::arg
  jsr print::print_hex
.endmacro
