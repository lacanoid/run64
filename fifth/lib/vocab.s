.proc vocab__reset_cursor
  Mov16 cursor,dbottom
  lda dbottom
  sta cursor
  lda dbottom+1
  sta cursor+1
    rts 
.endproc ; vocab__reset_cursor

.proc vocab__advance_cursor ; leaves high byte of cursor address in a
    ldy #3
    lda (cursor),y
    tax 
    iny 
    lda (cursor),y
    
    stx cursor
    sta cursor+1
    rts
.endproc ; vocab__advance_cursor
