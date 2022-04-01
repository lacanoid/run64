
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
  .ifnblank c
    lda #c
  .endif
  jsr CHROUT
.endmacro

.macro NewLine
  PrintChr 13
.endmacro

.macro NewLineSoft
  jsr print::new_line_soft
.endmacro

.macro ClearScreen 
  PrintChr 147
.endmacro
 
.macro IPrintHex arg1
  lda arg1+1
  jsr print::print_hex_digits
  lda arg1
  jsr print::print_hex_digits
.endmacro

.macro WPrintHex arg1
  lda #>(arg1)
  jsr print::print_hex_digits
  lda #<(arg1)
  jsr print::print_hex_digits
.endmacro

.macro BPrintHex arg1
  .ifnblank
    lda arg1
  .endif
  jsr print::print_hex_digits
.endmacro

.macro PrintZ arg1, offset
  .ifnblank offset
    ISet print::arg, {arg1+offset}
  .else
    ISet print::arg, {arg1}
  .endif
  jsr print::print_z
.endmacro

.macro PrintName arg1
  PrintZ arg1, vocab::name_offset
.endmacro
