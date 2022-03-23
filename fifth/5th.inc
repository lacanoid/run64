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
  .local foo
  .proc foo
    ldx #0
    loop:
      lda string,x
      beq done
      jsr CHROUT
      inx
    bne loop  
    beq done
    string: 
      .asciiz str
    done:
  .endproc
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

.include "lib/vocab.s"
.include "lib/parse.s"
.include "lib/interpret.s"
.include "lib/print.s"

.proc main
  bMov tmp_color, COLOR
  ColorSet 1
  ClearScreen
  PrintString "5TH 0.1"
  NewLine

  loop:
    ColorSet 1

    jsr getinput

    bMov COLOR, tmp_color

    jsr interpret
    
    bMov tmp_color, COLOR
    
    ColorSet 14
    jsr PRINT_STACK
    lda f_quit
    beq loop
    rts
    tmp_color: .byte 14
.endproc 

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

dbottom:
    .word VOCAB_START


f_quit:
    .byte 0

hex_result: .word 0

f_SP: .byte 0
STACK: .res 256
