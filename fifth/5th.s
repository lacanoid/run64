.include "../defs64.inc"
.include "macros/index.s"
cursor = $FB
input = BUF
TMP = $B0
  
PROG_START:
jmp main
.include "lib/index.s"
;.include "lib/dos.s"
VOCAB_START:
;.include "vocab/5mon.s"
.include "vocab/index.s"
main = rpl::main
HEAP_END:
  .word PROG_END
VOCAB_END:
PROG_END:
HEAP_START: