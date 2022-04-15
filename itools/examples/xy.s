jmp MAIN
.include "../../defs64.inc"
;.include "../ilib/xy.s"
MAIN:
wait: jsr GETIN
inc 53280
beq wait 
lda #'x'
jsr CHROUT
lda #'y'
jsr CHROUT
rts