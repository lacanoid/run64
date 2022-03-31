.include "dev.s"
.include "flow.s"
.include "math.s"
.include "stack.s"

PROC VLIST
  jsr vocab::reset_cursor
  print_entry:
    ldy #vocab::name_offset
    print_char:
      lda (vocab::cursor),y
      jsr CHROUT
      cmp #33
      bcc chars_done
      iny 
      bne print_char
    chars_done:
    PrintChr ' '
    jsr vocab::advance_cursor
    bne print_entry
  NewLine
  rts
END

PROC QUIT
  __next_entry__=0
  inc rpl::f_quit
  rts 
END
