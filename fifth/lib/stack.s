.scope indirect
  op: .byte 0
  address: .addr 0
  rts
.endscope


.align 2 
STACK: .res 64
f_SP: .byte 0

.scope stash
  .align 2 
  STACK: .res 64
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
    ldx stash::SP
    lda stash::STACK-2,x 
  .else 
    IMovIx arg1, stash::STACK-2, stash::SP
  .endif
.endmacro

.macro Unstash arg1
  dec stash::SP
  dec stash::SP
  .ifblank arg1
    ldx stash::SP
    lda stash::STACK,x 
  .else 
    IMovIx arg1, stash::STACK, stash::SP
  .endif
.endmacro


