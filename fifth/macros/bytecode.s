
.macro Run arg
  ISet runtime::IP, arg
  jsr runtime::run
.endmacro

.macro RunFrom arg
  IMov runtime::IP, arg
  jsr runtime::run
.endmacro

.macro RunStepOver
  jsr run_step_over 
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
  .addr EXIT
.endmacro

.macro _ arg, arg2, arg3, arg4, arg5, arg6, arg7, arg8
  .if .blank ({arg}) 
    rRet
  .elseif (.match (.left (1, {arg}), #))
    rInt (.right (.tcount ({arg})-1, {arg}))
  .elseif (.match (.left (1, {arg}), {""}))
    rStr arg
  .else 
    rRun arg 
  .endif
  .ifnblank arg2
    _ arg2
  .endif
  .ifnblank arg3
    _ arg3
  .endif  
  .ifnblank arg4
    _ arg4
  .endif
  .ifnblank arg5
    _ arg5
  .endif
  .ifnblank arg6
    _ arg6
  .endif  
  .ifnblank arg7
    _ arg7
  .endif
  .ifnblank arg8
    _ arg8
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

.macro ThrowError msg, code
  .scope 
    .pushseg
    .data
      .ifblank msg
        _msg_: .asciiz "ERROR"
      .else 
        _msg_: .asciiz msg
      .endif
    .popseg
    ISet ERROR_MSG, _msg_
    .ifblank code
      CSet ERROR_CODE, 1
    .else 
      CSet ERROR_CODE, code
    .endif
    sec
    rts
  .endscope
.endmacro