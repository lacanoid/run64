.feature c_comments
jmp MAIN

.include "defs-auto.inc"
.include "macros/basics.s"
.include "ilib/print.s"
.include "ilib/idump.s"

MAIN = idump::main