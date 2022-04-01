.include "../defs64.inc"
.include "macros/index.s"
TMP = $B0
  
PROG_START:
jmp MAIN
.include "lib/index.s"
;.include "lib/dos.s"
VOCAB_START:
;.include "vocab/5mon.s"
.include "vocab/index.s"
MAIN = rpl::main
DEFAULT_COMPILER = compiler::write_run
DEFAULT_LISTER = runtime::list_entry

HERE_PTR:
  .word PROG_END
VOCAB_END:
.align 16
PROG_END:
