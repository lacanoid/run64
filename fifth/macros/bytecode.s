
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
    .elseif DEF_PROC
    .endif
    .ifndef next
      next:
    .endif
  .endScope
.endmacro

.macro IF 
  .scope
  .byte runtime::_IF
  .word else
.endmacro

.macro ELSE 
  .byte runtime::_PTR
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
    .byte runtime::_IF
    .word break
.endmacro

.macro REPEAT
    .byte runtime::_PTR
    .word begin
    break:
  .endscope
.endmacro
