.macro entry name
    .local exec
    clc 
    bcc exec 
    .word next
    .asciiz name
    exec:
.endmacro

.include "dev.s"
.include "math.s"
.include "stack.s"
