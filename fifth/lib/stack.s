f_SP: .byte 0
STACK: .res 256

.scope stash
  STACK: .res 256
  SP: .byte 0
.endscope

.macro Stash arg1
  IxMov stash::STACK, stash::SP, arg1
  inc stash::SP
  inc stash::SP
.endmacro

.macro Unstash arg1
  dec stash::SP
  dec stash::SP
  IMovIx arg1, stash::STACK, stash::SP
.endmacro