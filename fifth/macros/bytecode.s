
.macro Run arg
  ISet runtime::IP, arg
  jsr runtime::run
.endmacro

.macro RunFrom arg
  IMov runtime::IP, arg
  jsr runtime::run
.endmacro


.macro rPtr arg
  .byte bytecode::tPTR
  .word arg
.endmacro

.macro rInt arg
  .byte bytecode::tINT
  .word arg
.endmacro

.macro rStr arg
  .scope 
    .byte bytecode::tSTR
    .word next
    .asciiz arg
    next:
  .endscope
.endmacro


.macro rRun arg
  .byte bytecode::tRUN
  .word arg
.endmacro

.macro rRet
  .byte bytecode::tRET
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
  .byte bytecode::tIF
  .word else
.endmacro

.macro ELSE 
  .byte bytecode::tELSE
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
    .byte bytecode::tBEGIN
    begin:
.endmacro

.macro WHILE
    .byte bytecode::tWHILE
    .word break
.endmacro

.macro AGAIN
    .byte bytecode::tAGAIN
    .word begin
    break:
  .endscope
.endmacro


.enum bytecode 
  tPTR 
  tRET 
  tINT 
  tSTR
  tRUN
  tIF
  tUNLESS
  tNOP
  tCTL = 15
  tELSE = tPTR + 16
  tTHEN = tNOP + 16
  tBEGIN = tNOP + 32
  tWHILE = tIF + 32
  tAGAIN = tPTR + 32
  tPROC = $4C
.endenum
