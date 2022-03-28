.include "../defs64.inc"
cursor = $FB
input = BUF
TMP = $B0
  
.include "macros/index.s"
jmp rpl::main
.include "lib/index.s"

HEAP_END:
  .word PROG_END
