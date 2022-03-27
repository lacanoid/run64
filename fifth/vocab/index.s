.include "dev.s"
.include "math.s"
.include "stack.s"

CMD cELSE,"ELSE"
  jmp compiler::write_else
END

CMD cTHEN,"THEN"
  jmp compiler::write_then
END

CMD cIF,"IF"
  jmp compiler::write_if
END

PROC VLIST
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

PROC QUIT
  next=0
  inc f_quit
  rts 
END
