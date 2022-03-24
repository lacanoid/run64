.include "../defs64.inc"
cursor = $FB
input = BUF
TMP = $FD

.include "macros/index.s"

.macro ColorSet c
    lda #c
    sta COLOR
.endmacro

.macro ColorPush c
    lda COLOR
    pha
    ColorSet c
.endmacro

.macro ColorPop
    pla
    sta COLOR
.endmacro


.macro PrintString str
  .scope
    ISet print::arg, data
    jsr print::print_z
    clc
    bcc exit
    data: 
      .asciiz str
    exit:
  .endscope
.endmacro



.macro PrintChr c
  lda #c
  jsr CHROUT
.endmacro

.macro NewLine
  PrintChr 13
.endmacro

.macro ClearScreen 
  PrintChr 147
.endmacro

jmp main

.include "lib/runtime.s"
.include "lib/stack.s"
.include "lib/vocab.s"
.include "lib/parse.s"
.include "lib/interpret.s"
.include "lib/print.s"
.include "lib/rpl.s"

main: JMP rpl::main

.proc getinput 
  ldx #0
  loop:
    jsr CHRIN
    sta BUF,X
    inx
    cpx #ENDIN-BUF   ; error if buffer is full
    bcs ierror
    cmp #13             ; keep reading until CR
  bne loop
  lda #0              ; null-terminate input buffer
  sta BUF-1,X         ; (replacing the CR)
  rts

  ierror:
    PrintString "??"
    rts
.endproc 

;.include "../utils.s"


f_quit:
    .byte 0
TOP:
  .word PROG_END
