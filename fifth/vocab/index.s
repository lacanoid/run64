.include "dev.s"
.include "flow.s"
.include "math.s"
.include "stack.s"

PROC VLIST
  jsr vocab::reset_cursor
  print_entry:
    jsr vocab::print_name_at_cursor
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
