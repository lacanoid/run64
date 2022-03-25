f_SP: .byte 0
STACK: .res 256

.scope stash
  STACK: .res 256
  SP: .byte 0
.endscope

.macro Stash arg1
  .if (.match (.left (1, {arg}), #))
    IxSet stash::STACK, stash::SP, (.right (.tcount ({arg})-1, {arg}))
  .else 
    IxMov stash::STACK, stash::SP, arg1
  .endif
  inc stash::SP
  inc stash::SP
.endmacro

.macro PeekStash arg1
  dec stash::SP
  dec stash::SP
  .ifblank arg1
    ldx stack::SP
    lda stash::STACK-2,x 
  .else 
    IMovIx arg1, stash::STACK-2, stash::SP
  .endif
.endmacro

.macro Unstash arg1
  dec stash::SP
  dec stash::SP
  .ifblank arg1
    ldx stack::SP
    lda stash::stack,x 
  .else 
    IMovIx arg1, stash::STACK, stash::SP
  .endif
.endmacro