
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
 
.macro IPrintHex arg1
  lda arg1+1
  jsr print::print_hex_digits
  lda arg1
  jsr print::print_hex_digits
.endmacro