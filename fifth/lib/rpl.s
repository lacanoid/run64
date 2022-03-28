.scope rpl 
  skip_depth:.byte 0 
  .proc do_debug
    ISet runtime::IP, HEAP_START
    ;ISet print::arg, HEAP_START
    ;jsr print::dump_hex
    Begin
      line:
      ColorPush 3
      jsr runtime::print_IP
      CClear runtime::ended
      PrintChr ' '
      ColorPop
      lda rstack::SP
      jsr print::print_hex_digits
      PrintChr ' '
      jsr runtime::describe_token
      PrintChr ' '

      jsr getinput
      CSet skip_depth, 127
      lda BUF
      and #$7F
      BraEq #'Q', break
      IfEq #'O'
        CMov skip_depth, rstack::SP
      EndIf
      IfEq #'P'
        CMov skip_depth, rstack::SP
        dec skip_depth
      EndIf
      IfEq #'R'
        CClear skip_depth
      EndIf
      IfEq #'S'
        NewLine
        ColorPush 1
        jsr PRINT_STACK
        ColorPop
        jmp next_line
      EndIf
      Begin
        jsr runtime::exec
        BraTrue runtime::ended, exit
        lda rstack::SP
        BraLt skip_depth, break
      Repeat
      PrintChr '<'
      BraTrue runtime::ended, exit
      next_line:
      NewLine
    Repeat
    exit:
    NewLine
    rts
  .endproc

  .proc do_line
    lda BUF
    IfEq #':'
      jsr compiler::compile_skip_first
      BraTrue compiler::error, catch      
      jsr do_debug
    Else
      jsr compiler::compile
      BraTrue compiler::error, catch 
      NewLine
      Run HEAP_START
    EndIf
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

    Begin
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
      BraTrue f_quit, break
    Repeat  
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