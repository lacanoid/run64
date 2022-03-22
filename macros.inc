.macro add arg
       clc 
       adc arg
.endmacro

.macro ldxy addr 
       ldx addr
       ldy addr+1
.endmacro

.macro stxy addr
       stx addr
       sty addr+1
.endmacro

.macro leaxy arg
       ldx #<arg
       ldy #>arg
.endmacro

.macro mov8 arg1,arg2
       lda arg2
       sta arg1
.endmacro
         
.macro mov arg1,arg2
       mov8 arg1,arg2
.endmacro
         
.macro mov16 arg1,arg2
       lda arg2
       sta arg1
       lda arg2+1
       sta arg1+1
.endmacro

.macro nop2
       .byte $24
.endmacro

.macro nop3
       .byte $2c
.endmacro
