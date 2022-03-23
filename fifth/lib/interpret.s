
.proc interpret
  Set8 offset, 0
  Set8 f_eof, 0
  Set8 f_error, 0
  loop:
    jsr skip_space
    IfTrue f_eof,break
    jsr next_word
    IfTrue f_error,catch
    jmp loop
  break:
    ColorSet 1
    PrintChr 'O'
    PrintChr 'K'
    NewLine
    rts
  catch:
    jsr print_error
    rts
.endproc

.proc print_error
  ColorSet 1
  PrintChr '?'
  ldx offset
  loop:
    lda input,x
    IfLt #33, done
    jsr CHROUT
    inx
    jmp loop
  done:
    NewLine
    rts 
.endproc

.proc skip_space 
  ldx offset
  loop:
    lda input,x
    IfEq #0, stop
    IfEq #13, stop
    IfGe #33, done
    inx
    jmp loop
  done:
    stx offset
    rts 
  stop:
    stx offset
    inc f_eof
    rts 
.endproc

.proc next_word
    lda input,x
    IfNe #'$', not_hex
  hex:
    jsr parse_hex 
    IfTrue f_error, not_found
    SpLoad
    PushFrom cursor
    rts 
  not_hex:
    IfLt #'0', not_dec
    IfGe #'9'+1, not_dec
  decimal:
    jsr parse_dec
    IfTrue f_error, not_found
    SpLoad
    PushFrom cursor 
    rts 
  not_dec:
  entry:
    jsr parse_entry
    IfTrue f_error, not_found
    jmp (cursor)
    rts 
  not_found:
    rts 
.endproc