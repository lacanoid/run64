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

.macro PrintMsg arg1
  ldy #arg1-MSGBAS
  jsr SNDMSG
.endmacro

.macro PrintChr c
  lda #c
  jsr CHROUT
.endmacro

.macro NewLine
  jsr CRLF
.endmacro

.macro ClearScreen
  PrintChr 147
.endmacro

jmp main

_dbottom:


.include "vocab/index.s"
.include "lib/interpret.s"
.include "lib/parse.s"
.include "lib/print.s"
.include "lib/vocab.s"

.proc main
  Mov8 tmp_color, COLOR
  ColorSet 1
  ClearScreen
  PrintMsg MSG0
  NewLine

  loop:
    ColorSet 1
    jsr getinput
    Mov8 COLOR, tmp_color
    jsr interpret
    Mov8 tmp_color, COLOR
    
    ColorSet 14
    jsr PRINT_STACK
    lda f_quit
    beq loop
    rts
    tmp_color: .byte 14
.endproc 

.proc getinput 
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
    PrintMsg MSG1   
    rts
.endproc 

.include "../utils.s"
; -----------------------------------------------------------------------------
; message table; last character has high bit set
MSGBAS  =*
MSG0:   .BYTE "*** 5TH 0.1 ***",13+$80
MSG1:   .BYTE "INPUT ERROR ",13+$80
MSG2:   .BYTE "****",13+$80


offset:
    .byte 0

dbottom:
    .word _dbottom

f_eof:
    .byte 0

f_error:
    .byte 0

f_quit:
    .byte 0

hex_result: .word 0

SP: .byte 0
STACK: .res 256
