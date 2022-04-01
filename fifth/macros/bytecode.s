
.macro Run arg
  ISet runtime::IP, arg
  jsr runtime::run
.endmacro

.macro RunFrom arg
  IMov runtime::IP, arg
  jsr runtime::run
.endmacro

.macro rInt arg
;  .byte bytecode::CTL
  .addr cINT
  .word arg
.endmacro

.macro rStr arg
  .scope 
 ;   .byte bytecode::CTL
    .addr cSTR
    .addr cont
    .asciiz arg
    cont:
  .endscope
.endmacro


.macro rRun arg
;  .byte bytecode::RUN
  .addr arg
.endmacro

.macro rRet
;  .byte bytecode::CTL
  .addr cRET
.endmacro

.macro _ arg
  .if .blank ({arg}) 
    rRet
  .elseif (.match (.left (1, {arg}), #))
    rInt (.right (.tcount ({arg})-1, {arg}))
  .elseif (.match (.left (1, {arg}), {""}))
    rStr arg
  .else 
    rRun arg 
  .endif
.endmacro

.macro IF 
  .scope
  ;.byte bytecode::CTL
  .addr cIF
  .word else
.endmacro

.macro ELSE 
  ;.byte bytecode::CTL
  .addr cELSE
  .word endif
  else:
.endmacro

.macro THEN
  ;.byte bytecode::CTL
  .addr cTHEN
  .ifndef else
    else:
  .endif
    endif:
  .endscope
.endmacro

.macro BEGIN
  .scope
    ;.byte bytecode::CTL
    .addr cBEGIN
    begin:
.endmacro

.macro RETURN
  rRet
.endmacro

.macro WHILE
    ;.byte bytecode::CTL
    .addr cWHILE
    .word break
.endmacro

.macro AGAIN
    ;.byte bytecode::CTL
    .addr cAGAIN
    .word begin
    break:
  .endscope
.endmacro

.enum bytecode 
  GTO 
  RET 
  INT 
  STR
  RUN
  IF0
  IF1
  NOP
  CTL = 15
  ELS = GTO + 16
  THN = NOP + 16
  BGN = NOP + 32
  WHL = IF0 + 32
  AGN = GTO + 32
  NAT = $4C
.endenum
