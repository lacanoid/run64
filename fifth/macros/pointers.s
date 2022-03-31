.macro Pointer label, arg
  .ifblank arg
    label: .addr 0
  .else
    label: .addr arg
  .endif
.endmacro

.macro PeekA pointer, offset
  .local rewrite
  IMov rewrite+1, pointer
  .ifnblank offset
    IAddB rewrite+1, offset
  .endif
  rewrite:
  lda $DEFA
.endmacro

.macro PokeA pointer, offset
  .local rewrite
  pha
  IMov rewrite+1, pointer
  .ifnblank offset
    IAddB rewrite+1, offset
  .endif
  pla
  rewrite:
  sta $FEDA
.endmacro

.macro IGet target, address, offset
  .local rewrite
  IMov rewrite+1, address
  .ifnblank offset
    IAddB rewrite+1, offset
  .endif
  Imov rewrite+1,rewrite2+1
  IInc rewrite2
  rewrite:
  lda $DEFA
  sta target
  rewrite2:
  lda $DEFA
  sta target+1
.endmacro

.macro ReadA address
  ;NewLine
  ;IPrintHex {address}
  ;PrintChr '='
  PeekA {address}
  pha
  ;jsr print::print_hex_digits
  IInc address
  pla 
.endmacro

.macro WriteA address
  PokeA {address}
  IInc {address}
.endmacro


.macro PeekX pointer, offset
  .local rewrite
  IMov rewrite+1, pointer
  .ifnblank offset
    ldx #offset
  .endif
  rewrite:
  lda $DEFA,x 
.endmacro

.macro PeekY pointer, offset
  .local rewrite
  IMov rewrite+1, pointer
  .ifnblank offset
    ldy #offset
  .endif
  rewrite:
  lda $DEFA,y 
.endmacro

.macro PokeX pointer, offset
  .local rewrite
  IMov rewrite+1, pointer
  .ifnblank offset
    ldx #offset
  .endif
  rewrite:
  sta $DEFA,x 
.endmacro

.macro PokeY pointer, offset
  .local rewrite
  IMov rewrite+1, pointer
  .ifnblank offset
    ldy #offset
  .endif
  rewrite:
  sta $DEFA,y 
.endmacro
