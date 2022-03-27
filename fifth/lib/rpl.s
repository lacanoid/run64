.scope rpl 
  .proc do_line
    lda BUF
    IfEq #':', compile
      jsr compiler::compile
      IfTrue compiler::error, catch 
      NewLine
      Run HEAP_START
      jmp done
    compile:
      jsr compiler::compile_skip_first
      IfTrue compiler::error, catch      
      ;Run HDUMP
      Run H
      
    done:
      ColorPush 3
      PrintChr 'O'
      PrintChr 'K'
      ColorPop
      rts
    catch:
      ColorPush 10
      PrintChr '?'
      jsr compiler::print_next_word
      ColorPop
      rts 
  .endproc 

  .proc main
    ISet 53280,0
    CMov tmp_color, COLOR
    ColorSet 1
    ClearScreen
    PrintString "5TH 0.1"
    NewLine

    loop:
      ColorSet 1

      jsr getinput

      CMov COLOR, tmp_color
      NewLine

      jsr do_line    

      CMov tmp_color, COLOR
      
      ColorSet 3
      Run PRINT_STACK
      PrintChr ' '
      ColorSet 4      
      ; Run HSIZE
      ; Run DEC
      NewLine
      lda f_quit
      beq loop
      rts
      tmp_color: .byte 14
  .endproc 
.endscope