.scope vocab 
  next_offset = 3
  token_offset = 5
  compile_offset = 6
  list_offset = 8
  name_offset = 10
  cursor = $FB
  bottom: .addr VOCAB_START
  arg: .addr 0

  .proc reset_cursor
    IMov cursor, bottom
    rts 
  .endproc ; vocab::reset_cursor

  .proc advance_cursor ; leaves high byte of cursor address in a
    ldy #next_offset
    lda (cursor),y
    tax 
    iny 
    lda (cursor),y
    
    stx cursor
    sta cursor+1
    rts
  .endproc ; vocab::advance_cursor

  .proc print_name
    IMov print::arg, arg
    IAddB print::arg, name_offset
    jsr print::print_z
    rts
  .endproc
.endscope