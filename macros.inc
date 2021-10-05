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
         
.macro msg addr 
       leaxy addr 
       jsr msgout
.endmacro  

.macro chrout c
       lda #c 
       jsr CHROUT
.endmacro