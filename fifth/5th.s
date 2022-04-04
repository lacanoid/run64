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
/*jumper:


  ldi ff, #foo
  ldi cc, #2000
  pri ff, "ADDR"
  pri xf, "DATA"
  ldi ee, foo
  pri ee, "CTRL"

  NewLine
  ldi cc, #$2000
  pri cc, "SET"
  mvi xf, cc
  pri xf, "RES"
  NewLine

  ldi cc, #$abff
  pri cc, "ADI"
  adi cc, #2
  pri cc, "C"
  ldi dd, #16
  adi cc, dd
  pri cc, "R"
  ldi dd, #(foo+4)
  adi cc, xd
  pri cc, "I"
  pri xd
  adi cc, foo
  pri cc, "M"
  NewLine

  ldi cc, #$1101
  pri cc, "SBI"
  sbi cc, #2
  pri cc, "C"
  ldi dd, #16
  sbi cc, dd
  pri cc, "R"
  ldi dd, #(foo+4)
  sbi cc, xd
  pri cc, "I"
  sbi cc, =foo+4
  pri cc, "M"

  NewLine
  ini cc
  pri cc, "INI"
  ini xd
  pri xd, "I"

  NewLine

  phi sp, xf
  pri xf, "PHI"

  ldi cc, #$1234
  phi sp, cc
  pri cc, "PHI"

  ldi cc, #$ABCD
  pri cc, "CHNG"

  pli cc, sp
  pri cc, "PLI"

  pli cc, sp
  pri cc, "PLI"

  jmp MAIN
*/
foo: .word $1000
.word $100
.word $10
    

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

