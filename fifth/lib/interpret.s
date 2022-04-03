
.proc interpret
  jsr parse::reset
  
  loop:
    jsr parse::skip_space
    BraTrue parse::eof, done
    jsr parse::next_word
    BraTrue parse::error, catch
    jmp loop
  done:
    ColorPush 3
    PrintChr 'O'
    PrintChr 'K'
    ColorPop
    
    rts
  catch:
    jsr print_error
    rts
.endproc

.proc print_error
  ColorPush 10
  
  PrintChr '?'
  jsr parse::print_next_word
  ColorPop
  rts 
.endproc
