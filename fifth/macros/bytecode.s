
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
  .byte bytecode::tPTR
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
    begin:
.endmacro

.macro WHILE
    .byte bytecode::tIF
    .word break
.endmacro

.macro REPEAT
    .byte bytecode::tPTR
    .word begin
    break:
  .endscope
.endmacro

.scope bytecode 
  tJMP = $4C
  tPTR = 0
  tRET = 1
  tINT = 2
  tSTR = 3
  tJSR = 4
  tRUN = 5
  tIF = 6 
  tCTL = 7
  tSKIP = 8
  tELSE = tPTR + 16
  tTHEN = tSKIP + 16
  
.endscope