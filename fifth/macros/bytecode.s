
.macro Run arg
  ISet runtime::IP, arg
  jsr runtime::run
.endmacro

.macro RunFrom arg
  IMov runtime::IP, arg
  jsr runtime::run
.endmacro


.macro rPtr arg
  .byte bytecode::GTO
  .word arg
.endmacro

.macro rInt arg
  .byte bytecode::INT
  .word arg
.endmacro

.macro rStr arg
  .scope 
    .byte bytecode::STR
    .addr next
    .asciiz arg
    next:
  .endscope
.endmacro


.macro rRun arg
  .byte bytecode::RUN
  .addr arg
.endmacro

.macro rRet
  .byte bytecode::RET
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

.macro CMD name, label
  .scope
    DEF_CMD = 1
    cEntry name, label
.endmacro

.macro PROC name, label
  .scope
    DEF_PROC = 1
    jEntry name, label
.endmacro

.macro DEF name, label
  .scope
    DEF_RUN = 1
    rEntry name, label
.endmacro

.macro DATA
  rRet
  data:
.endmacro

.macro END name, label
    .ifdef DEF_RUN 
      .ifndef data 
        rRet
      .endif
    .elseif .def (DEF_PROC)
    .endif
    .ifndef next
      next:
    .endif
  .endScope
.endmacro

.macro IF 
  .scope
  .byte bytecode::IF0
  .word else
.endmacro

.macro ELSE 
  .byte bytecode::ELS
  .word endif
  else:
.endmacro

.macro ENDIF
  .ifndef else
    else:
  .endif
    endif:
  .endscope
.endmacro

.macro BEGIN
  .scope
    .byte bytecode::BGN
    begin:
.endmacro

.macro WHILE
    .byte bytecode::WHL
    .word break
.endmacro

.macro AGAIN
    .byte bytecode::AGN
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
