.feature c_comments
.feature loose_string_term

.include "../defs64.inc"
.include "macros/index.s"
TMP = $FD
HEAP_START = $C000
PROG_START:

jmp MAIN
.include "lib/vmd.s"
.include "lib/index.s"


foo: .word $1234
.word $DEFA
    

;.include "lib/dos.s"
VOCAB_START:
;.include "vocab/5mon.s"
.include "vocab/index.s"
MAIN = interpreter::rpl
DEFAULT_COMPILER = compiler::write_run
DEFAULT_LISTER = runtime::list_entry

HERE: .word PROG_END
HEAP_END: .word HEAP_START

VOCAB_END:
.align 16
PROG_END:

