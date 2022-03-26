.include "dev.s"
.include "math.s"
.include "stack.s"

PROC QUIT
  inc f_quit
  rts 
END

PROC VLIST
  next=0
  jsr vocab::reset_cursor
  print_entry:
    ldy #5
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