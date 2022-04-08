.feature c_comments
jmp MAIN

.include "defs-auto.inc"
.include "macros/basics.s"
.include "imenu_lib/print.s"
.include "imenu_lib/idump.s"

MAIN = idump::main