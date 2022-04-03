.scope rpl 
  f_quit:     .byte 0
  skip_depth: .byte 0

  .proc do_debug
    ISet IP, compiler::CBUF
    jsr runtime::reset
    jmp debug::do_debug
  .endproc

  .proc do_line
    lda BUF
    IfEq #':'
      jsr compiler::compile_skip_first
      BraTrue compiler::error, catch      
      jsr do_debug
    Else
      jsr compiler::compile_line
      BraTrue compiler::error, catch
      NewLine
      ;Run compiler::CBUF
    EndIf
    IfFalse compiler::creating
      ColorPush 3
      PrintString "OK"
      ColorSet 4
      jsr PRINT_STACK
      ColorPop
    EndIf
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
    jsr compiler::reset
    Begin
      ColorSet 3
      IfTrue compiler::creating
        PrintChr '>'
      Else
        ;PrintChr '$'
      EndIf
      ColorSet 1

      jsr getinput

      CMov COLOR, tmp_color
      NewLineSoft

      jsr do_line    

      CMov tmp_color, COLOR
      
      NewLineSoft
      BraTrue f_quit, break
    Again
    PrintString "BYE."
    rts
    tmp_color: .byte 14
  .endproc 

  .proc getinput 
  ldx #0
  loop:
    jsr CHRIN
    sta BUF,X
    inx
    cpx #ENDIN-BUF   ; error if buffer is full
    bcs ierror
    cmp #13             ; keep reading until CR
  bne loop
  lda #0              ; null-terminate input buffer
  sta BUF-1,X         ; (replacing the CR)
  rts

  ierror:
    PrintString "??"
    rts
  .endproc 

.endscope

