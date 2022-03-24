.macro Stash arg1
  IxMov runtime::STACK, runtime::SP, arg1
  inc runtime::SP
  inc runtime::SP
.endmacro

.macro Unstash arg1
  dec runtime::SP
  dec runtime::SP
  IMovIx arg1, runtime::STACK, runtime::SP
.endmacro

  
.scope runtime
  STACK: .res 256
  SP: .byte 0
.endscope 
