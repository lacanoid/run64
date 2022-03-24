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
      jsr interpret
    
      CMov tmp_color, COLOR
      
      ColorSet 3
      Exec PRINT_STACK
      PrintChr ' '
      ColorSet 4      
      Exec HSIZE
      Exec DEC
      NewLine
      lda f_quit
      beq loop
      rts
      tmp_color: .byte 14
  .endproc 
.endscope