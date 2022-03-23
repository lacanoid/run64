.macro Entry name
    .local exec
    clc 
    bcc exec 
    .word next
    .asciiz name
    exec:
.endmacro

.macro Exec entry
  jsr entry
.endmacro

.scope vocab 
  cursor = $FB
  bottom: .word VOCAB_START

  .proc reset_cursor
    iMov cursor, bottom
    rts 
  .endproc ; vocab::reset_cursor

  .proc advance_cursor ; leaves high byte of cursor address in a
    ldy #3
    lda (cursor),y
    tax 
    iny 
    lda (cursor),y
    
    stx cursor
    sta cursor+1
    rts
  .endproc ; vocab::advance_cursor
.endscope