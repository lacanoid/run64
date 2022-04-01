.macro Pointer label, argp
  .ifblank argp
    label: .addr 0
  .else
    label: .addr argp
  .endif
.endmacro

.macro PeekA argp, offset
  .local rewrite
  IMov rewrite+1, argp
  .ifnblank offset
    IAddB rewrite+1, offset
  .endif
  rewrite:
  lda $DEFA
.endmacro

.macro PokeA argp, offset
  .local rewrite
  pha
  IMov rewrite+1, argp
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


.macro PeekX argp, offset
  .local rewrite
  IMov rewrite+1, argp
  .ifnblank offset
    ldx #offset
  .endif
  rewrite:
  lda $DEFA,x 
.endmacro

.macro PeekY argp, offset
  .local rewrite
  IMov rewrite+1, argp
  .ifnblank offset
    ldy #offset
  .endif
  rewrite:
  lda $DEFA,y 
.endmacro

.macro PokeX argp, offset
  .local rewrite
  pha
  IMov rewrite+1, argp
  pla
  .ifnblank offset
    ldx #offset
  .endif
  rewrite:
  sta $DEFA,x 
.endmacro

.macro PokeY argp, offset
  .local rewrite
  pha 
  IMov rewrite+1, argp
  pla
  .ifnblank offset
    ldy #offset
  .endif
  rewrite:
  sta $DEFA,y 
.endmacro

.macro ReadX argp, offset
  PeekX argp, offset
  inx
.endmacro

.macro ReadY argp, offset
  PeekY argp, offset
  iny
.endmacro

.macro WriteX argp, offset
  PokeX argp, offset
  inx
.endmacro

.macro IWriteX argp, address, offset
  lda address
  PokeX argp, offset
  inx
  lda address+1
  PokeX argp
  inx
.endmacro

.macro WriteY argp, offset
  PokeY argp, offset
  iny
.endmacro

.macro IWriteY argp, address, offset
  lda address
  WriteY argp, offset
  lda address+1
  WriteY argp
.endmacro

.macro WriteXB argp, value, offset
  lda #value
  PokeX argp, offset
  inx
.endmacro

.macro WriteXW argp, value, offset
  WriteXB argp, <(value), offset
  WriteXB argp, >(value)
.endmacro

.macro WriteYB argp, value, offset
  lda #value
  PokeY argp, offset
  iny
.endmacro

.macro WriteYW argp, value, offset
  WriteYB argp, <(value), offset
  WriteYB argp, >(value)
.endmacro