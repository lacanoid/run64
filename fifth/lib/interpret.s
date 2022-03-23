
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
  ldx parse::offset
  loop:
    lda input,x
    IfLt #33, done
    jsr CHROUT
    inx
    jmp loop
  done:
    NewLine
    ColorPop
    rts 
.endproc
