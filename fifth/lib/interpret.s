
.proc interpret
  jsr parse::reset
  
  loop:
    jsr parse::skip_space
    IfTrue parse::eof, done
    jsr parse::next_word
    IfTrue parse::error, catch
    jmp loop
  done:
    ColorPush 1
    PrintChr 'O'
    PrintChr 'K'
    ColorPop
    NewLine
    rts
  catch:
    jsr print_error
    rts
.endproc

.proc print_error
  ColorPush 1
  PrintChr '?'
  jsr parse::print_next_word
  NewLine
  ColorPop
  rts 
.endproc
