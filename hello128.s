; Automated test for C64 autostart (use with VICE -debugcart and -limitcycles 
; options).

.include "defs.inc"
.include "macros.inc"

.segment "STARTUP"

.segment "LOWCODE"

main:
        leaxy hello
        jsr msgout
        rts

hello:  .byte 14
        .asciiz "HELLO, WORLD!"
;
msgout:  stx T1
         sty T2
         ldy #0
moprint: lda (T1),y
         beq @modone
         jsr CHROUT
         iny
         bpl moprint
@modone:
         rts

.segment "INIT"

