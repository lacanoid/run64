.scope rpl 

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
      
      jsr compiler::compile
      Run HEAP_START  
      
      CMov tmp_color, COLOR
      
      ColorSet 3
      Run PRINT_STACK
      PrintChr ' '
      ColorSet 4      
      Run HSIZE
      Run DEC
      NewLine
      lda f_quit
      beq loop
      rts
      tmp_color: .byte 14
  .endproc 
.endscope