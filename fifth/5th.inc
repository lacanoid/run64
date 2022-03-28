.include "../defs64.inc"
cursor = $FB
input = BUF
TMP = $B0
  
.include "macros/index.s"

jmp main

.include "lib/stack.s"
.include "lib/print.s"
.include "lib/vocab.s"
.include "lib/runtime.s"
.include "lib/compiler.s"
.include "lib/rpl.s"

main: JMP rpl::main


;.include "../utils.s"


f_quit:
    .byte 0
HEAP_END:
  .word PROG_END
